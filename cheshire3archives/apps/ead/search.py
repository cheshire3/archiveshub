"""EAD Search WSGI Application."""

import sys
import os
import socket
import webbrowser

from cgi import FieldStorage
from argparse import ArgumentParser

# Cheshire3 Imports
from cheshire3.cqlParser import Diagnostic as CQLDiagnostic
from cheshire3.cqlParser import SearchClause as CQLClause, Triple as CQLTriple
from cheshire3.baseObjects import ResultSet
from cheshire3.web.www_utils import generate_cqlQuery

# Cheshire3 for Archives Imports
from cheshire3archives.commands.utils import WSGIAppArgumentParser
from cheshire3archives.apps.ead.base import *


class EADSearchWsgiApplication(EADWsgiApplication):
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        # Prepare application to handle a new request
        self._setUp(environ)
        path = environ.get('PATH_INFO', '').strip('/')
        form = FieldStorage(fp=environ['wsgi.input'], environ=environ)
        operation = form.getvalue('operation', None)
        if operation is None:
            # Filename based?
            operation = os.path.splitext(path.split('/')[-1])[0]
        
        # Check operation and act accordingly
        if not operation or operation == 'index':
            content = [self._render_template('index.html')]
        else:
            try:
                fn = getattr(self, operation)
            except AttributeError:
                # Check for static content request
                if path.startswith(('css', 'img', 'js', 'ead')):
                    content = self._static_content(path)
                    if content:
                        start_response("200 OK", self.response_headers)
                    else:
                        start_response("404 NOT FOUND", self.response_headers)
                        content = [self._render_template(
                                       'fail/404.html',
                                       resource=path
                                   )]
                else:
                    # Invalid operation selected
                    self.htmlTitle.append('Error')
                    start_response("404 NOT FOUND", self.response_headers)
                    content = [
                        self._render_template(
                            'fail/invalidOperation.html',
                            operation=operation
                        )
                    ]
                return content
            else:
                # Simple method of self
                content = fn(form)
        response_headers = [('Content-Type',
                             'text/html'),
                            ('Content-Length',
                             str(sum([len(d) for d in content])))
                            ]
        start_response("200 OK", response_headers)
        return content

    def _format_query(self, query):
        u"""Format simple query and return user friendly text form.
        
        For complex (multi-clause) queries, will return an empty string,
        except in the special case where Keywords are being searched for
        """
        try:
            # Check for single clause query
            idx = query.index
            rel = query.relation.value
            term = query.term.toCQL()
        except AttributeError:
            try:
                # Check for special "keywords" multi-clause query
                idx = query.leftOperand.leftOperand.index
                if idx.toCQL() != u'cql.anywhere':
                    return u''
                rel = query.leftOperand.leftOperand.relation.value
                term = query.leftOperand.leftOperand.term.toCQL()
            except AttributeError:
                return u''
        if idx is None:
            return u''
        elif idx.toCQL() == u'cql.anywhere':
            displayIdx = u''
        else:
            if idx.toCQL() == u'dc.identifier':
                displayName = u'Ref numbers'
            elif idx.toCQL() == u'bath.personalname':
                displayName = u'People'
            elif idx.toCQL() == u'bath.corporatename':
                displayName = u'Organizations'
            elif idx.toCQL() == u'bath.geographicname':
                displayName = u'Places'
            elif idx.toCQL() == u'bath.genreform':
                displayName = u'Media Types'
            else:
                displayName = idx.value.title() + u's'
            displayIdx = u' in <strong>{0}</strong>'.format(displayName)
        return u'''You searched for <strong>{0}</strong>{1}.'''.format(term, displayIdx)

    def _get_query(self, form):
        session = self.session
        queryFactory = self.queryFactory
        qString = form.getvalue('query')
        rsid = form.getvalue('rsid', None)
        filter_ = form.getvalue('filter', '')
        withinCollection = form.getvalue('withinCollection', None)
        if rsid:
            qString = 'cql.resultSetId = "{0}/{1}"'.format(
                self.resultSetStore.id,
                rsid
            )
        elif not qString:
            qString = generate_cqlQuery(form)
            if not (len(qString)):
                self._log(40, '*** Unable to generate CQL query')
                return self._render_template('fail/invalidQuery.html')
        if filter_:
            qString = '{0} and/relevant/proxinfo ({1})'.format(filter_,
                                                               qString)
        if (withinCollection and withinCollection != 'allcollections'):
            qString = ('(c3.idx-docid exact "%s" or '
                       'ead.parentid exact "%s/%s") and/relevant/proxinfo '
                       '(%s)'
                       '' % (withinCollection,
                             recordStore.id,
                             withinCollection,
                             qString
                             )
                       )
        elif 'noComponents' in form:
            qString = ('ead.istoplevel=1 and/relevant/proxinfo (%s)'
                       '' % qString)
        try:
            return queryFactory.get_query(session, qString, format="cql")
        except CQLDiagnostic:
            self._log(40, '*** Unparsable query: %s' % qString)
            if (qString.count('"') % 2):
                return self._render_template('fail/unpairedQuotes.html')
            else:
                return self._render_template('fail/invalidQuery.html')

    def _searchAndSort(self, form):
        # Process form and returns a ResultSet
        session = self.session
        db = self.database
        rsid = form.getvalue('rsid', None)
        sortBy = form.getlist('sortBy')
        if rsid and not 'filter' in form:
            try:
                rs = self._fetch_resultSet(session, rsid)
            except c3errors.ObjectDoesNotExistException:
                self._log(40, '*** Invalid ResultSet identifier: %s' % rsid)
                return self._render_template('fail/invalidResultSet.html',
                                             rsid=rsid)
        else:
            query = self._get_query(form)
            if not isinstance(query, (CQLClause, CQLTriple)):
                # Error message
                return query
            self._log(20, 'Searching CQL query: %s' % (query.toCQL()))
            rs = db.search(session, query)
            if len(rs):
                # Store the Query
                query = self._store_query(session, query)
                # Store the Resultset
                rs.id = query.id
                self._store_resultSet(session, rs)
            else:
                # Log 0 result?
                pass
        if sortBy:
            for spec in reversed(sortBy):
                rs.order(session, spec)
        return rs
    
    def search(self, form):
        if not form:
            # Simply return the search form
            return [self._render_template('search.html')]
        session = self.session
        sortBy = form.getlist('sortBy')
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        rs = self._searchAndSort(form)
        if not isinstance(rs, ResultSet):
            # Error message
            return [rs]
        queryString = self._format_query(rs.query)
        facets = self.facets(rs)
        if len(rs):
            return [self._render_template('searchResults.html',
                                          session=session,
                                          queryString=queryString,
                                          resultSet=rs,
                                          sortBy=sortBy,
                                          maximumRecords=maximumRecords,
                                          startRecord=startRecord, 
                                          facets=facets
                                          )]
        else:
            return [self._render_template('fail/noHits.html',
                                          queryString=queryString)]

    def lastResultSet(self, form):
        raise NotImplementedError()

    def similar(self, form):
        raise NotImplementedError()
    
    def facets(self, rs):
        session = self.session
        db = self.database
        pm = db.get_path(session, 'protocolMap')
        if not pm:
            db._cacheProtocolMaps(session)
            pm = db.protocolMaps.get('http://www.loc.gov/zing/srw/')
        facets = {}
        for idx in ['dc.subject', 'dc.creator']:
            query = self.queryFactory.get_query(session,
                                                '{0}="*"'.format(idx),
                                                format='cql')
            idxObj = pm.resolveIndex(session, query)
            try:
                facets[idx] = idxObj.facets(session, rs)
            except:
                self._log(40, "Couldn't get facets from {0}".format(idx))
                raise
        return facets

    def browse(self, form):
        if not form:
            # Simply return the search form
            return [self._render_template('browse.html')]
        session = self.session
        idx = form.getfirst('fieldidx1', None)
        rel = form.getfirst('fieldrel1', 'exact')
        scanTerm = form.getfirst('fieldcont1', '')
        startTerm = int(form.getfirst('startTerm',
                                      form.getfirst('firstrec', 1)))
        maximumTerms = int(form.getfirst('maximumTerms',
                                         form.getfirst('numreq', 25)))
        scanData = self._scanIndex(form)
        if not isinstance(scanData, dict):
            return scanData
        else:
            scanTermNorm, (hitstart, scanData, hitend) = scanData.popitem()
        if not len(scanData):
            return [self._render_template('fail/noTerms.html')]
        return [self._render_template('browseResults.html',
                                      idx=idx,
                                      rel=rel,
                                      scanTerm=scanTermNorm,
                                      scanData=scanData,
                                      startTerm=startTerm,
                                      maximumTerms=maximumTerms,
                                      hitstart=hitstart,
                                      hitend=hitend
                                      )]

    def subject(self, form):
        if not form:
            # Simply return the search form
            return [self._render_template('subject.html')]
        raise NotImplementedError()

    def summary(self, form):
        session = self.session
        db = self.database
        sortBy = form.getlist('sortBy')
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        hit = int(form.getvalue('hit', 0))
        rs = self._searchAndSort(form)
        if not isinstance(rs, ResultSet):
            # Error message
            return rs
        queryString = self._format_query(rs.query)
        rec = rs[hit].fetch_record(session)
        # Save rec.id now
        recid = rec.id
        # Highlight search terms
        highlighter = db.get_object(session, 'highlightTxr')
        doc = highlighter.process_record(session, rec)
        xmlp = db.get_object(session, 'LxmlParser')
        rec = xmlp.process_document(session, doc)
        self._log(10, 'Search terms highlighted')
        summaryTxr = db.get_object(session, 'htmlSummaryTxr')
        doc = summaryTxr.process_record(session, rec)
        page = self._render_template('summary.html',
                                     session=session,
                                     queryString=queryString,
                                     resultSet=rs,
                                     sortBy=sortBy,
                                     maximumRecords=maximumRecords,
                                     startRecord=startRecord, 
                                     doc=doc
                                     )
        page = page.replace('SCRIPT', self.script)
        page = page.replace('DATAURL', '{0}/data'.format(self.script))
        page = page.replace('RECID', recid)
        return page

    def full(self, form):
        raise NotImplementedError()

    def toc(self, form):
        raise NotImplementedError()

    def email(self, form):
        raise NotImplementedError()


def main(argv=None):
    """Start up a simple app server to serve the application."""
    global argparser, application
    from wsgiref.simple_server import make_server
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    httpd = make_server(args.hostname, args.port, application)
    url = "http://{0}:{1}".format(args.hostname, args.port)
    if args.browser:
        webbrowser.open(url)
        print ("Hopefully a new browser window/tab should have opened "
               "displaying the application.")
        print "If not, you should be able to access the application at:"
    else:
        print "You should be able to access the application at:"
        
    print url
    return httpd.serve_forever()


application = EADSearchWsgiApplication(session, db, config)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == "__main__":
    sys.exit(main())