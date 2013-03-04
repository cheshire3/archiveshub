"""EAD Search WSGI Application."""

import sys
import os
import socket
import webbrowser
import textwrap

from cgi import FieldStorage
from argparse import ArgumentParser

# Cheshire3 Imports
from cheshire3.cqlParser import Diagnostic as CQLDiagnostic
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
            content = self._render_template('search.html')
        else:
            try:
                fn = getattr(self, operation)
            except AttributeError:
                # Check for static content request
                if path.startswith(('css', 'img', 'js', 'ead')):
                    content = self._static_content(path)
                    if not content:
                        start_response("404 NOT FOUND", self.response_headers)
                        self.htmlTitle.append('Error')
                        content = ('<p class="error">',
                                   'An invalid resource was requested. ',
                                   '</p>'
                                   )
                    else:
                        start_response("200 OK", self.response_headers)
                        return content
                else:
                    # Invalid operation selected
                    self.htmlTitle.append('Error')
                    start_response("404 NOT FOUND", self.response_headers)
                    content = ('<p class="error">',
                               'An invalid operation was attempted. ',
                               'Valid operations are:<br/>',
                               'search, browse, resolve, summary, full, toc, email',
                               '</p>'
                               )
                return content
            else:
                # Simple method of self
                try:
                    content = fn(form)
                except:
                    content = self._handle_error()
                    raise
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

    def search(self, form):
        session = self.session
        db = self.database
        queryFactory = self.queryFactory
        rsid = form.getvalue('rsid', None)
        qString = form.getvalue('query')
        withinCollection = form.getvalue('withinCollection', None)
        sortBy = form.getlist('sortBy')
        maximumRecords = int(form.getvalue('numreq', 20))
        startRecord = int(form.getvalue('firstrec', 0))
        if (rsid):
            rs = self._fetch_resultSet(session, rsid)
        else:
            if not qString:
                qString = generate_cqlQuery(form)
                if not (len(qString)):
                    self._log(40, '*** Unable to generate CQL query')
                    return self._render_template('fail/invalidQuery.html')
                
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
            
            self._log(20, 'Searching CQL query: %s' % (qString))
            try:
                query = queryFactory.get_query(session, qString, format="cql")
            except CQLDiagnostic:
                self._log(40, '*** Unparsable query: %s' % qString)
                if (qString.count('"') % 2):
                    return self._render_template('fail/unpairedQuotes.html')
                else:
                    return self._render_template('fail/invalidQuery.html')
            rs = db.search(session, query)
            # Store the resultSet
            rss = db.get_object(session, 'eadResultSetStore')
            rss.create_resultSet(session, rs)
        if sortBy:
            for spec in reversed(sortBy):
                rs.order(session, spec)
        queryString = self._format_query(rs.query)
        if len(rs):
            return self._render_template('searchResults.html',
                                         session=session,
                                         queryString=queryString,
                                         resultSet=rs,
                                         sortBy=sortBy,
                                         maximumRecords=maximumRecords,
                                         startRecord=startRecord, 
                                         facets={}
                                         )
        else:
            return self._render_template('fail/noHits.html',
                                         queryString=queryString)

    def lastResultSet(self, form):
        raise NotImplementedError()

    def similar(self, form):
        raise NotImplementedError()

    def facet(self, form):
        raise NotImplementedError()

    def browse(self, form):
        raise NotImplementedError()

    def subject(self, form):
        raise NotImplementedError()

    def summary(self, form):
        raise NotImplementedError()

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