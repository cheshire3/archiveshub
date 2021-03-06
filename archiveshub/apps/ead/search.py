"""EAD Search WSGI Application."""

import inspect
import sys
import os
import webbrowser
import smtplib
import textwrap

from webob.exc import *
# Email modules
from email import Message, MIMEMultipart, MIMEText

# Cheshire3 Imports
from cheshire3.cqlParser import Diagnostic as CQLDiagnostic
from cheshire3.cqlParser import SearchClause as CQLClause, Triple as CQLTriple
from cheshire3.baseObjects import ResultSet
from cheshire3.exceptions import (
    ObjectDeletedException,
    ObjectDoesNotExistException
)
from cheshire3.web.www_utils import generate_cqlQuery

# Cheshire3 for Archives Imports
from archiveshub.deploy.utils import WSGIAppArgumentParser
from archiveshub.apps.ead.base import EADWsgiApplication
from archiveshub.apps.ead.base import config, session, db


class EADSearchWsgiApplication(EADWsgiApplication):

    def __init__(self, config, session, database):
        super(EADSearchWsgiApplication, self).__init__(
            config,
            session,
            database
        )
        # Fetch Logger
        self.logger = database.get_object(
            session,
            'searchTransactionLogger'
        )

    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        try:
            # Prepare application to handle a new request
            self._setUp(environ)
            path = self.request.path_info.strip('/')
            form = self._get_params()
            operation = form.get('operation', None)
            if operation is None:
                # Filename based?
                operation = os.path.splitext(path.split('/')[-1])[0]
            # Check operation and act accordingly
            if not operation or operation == 'index':
                self.response.body = self._render_template('index.html')
            elif operation in ['explore', 'searchContributor']:
                # Serve simple templated page
                self.response.body = self._render_template(
                    '{0}.html'.format(operation)
                )
            elif operation == 'help':
                # Redirect to help pages
                response = HTTPTemporaryRedirect(
                    location="http://archiveshub.ac.uk/searchhelp/"
                )
                return response(environ, start_response)
            else:
                try:
                    fn = getattr(self, operation)
                except AttributeError:
                    # Check for static content request
                    if path.startswith(('css', 'img', 'js', 'ead')):
                        self.response.app_iter = self._static_content(path)
                        contentlen = sum([len(d)
                                          for d
                                          in self.response.app_iter
                                          ])
                        if contentlen:
                            self.response.content_length = contentlen
                        else:
                            self.response.status = 404
                            self.response.body = self._render_template(
                                'fail/404.html',
                                resource=path
                            )
                    else:
                        # Invalid operation selected
                        self.response.status = 404
                        self.response.body = self._render_template(
                            'fail/invalidOperation.html',
                            operation=operation,
                            available=[
                                method[0]
                                for method
                                in inspect.getmembers(self, inspect.ismethod)
                                if not method[0].startswith('_')
                            ]
                        )
                    return self.response(environ, start_response)
                else:
                    # Simple method of self
                    # May be a generator
                    body = fn(form)
                    if isinstance(body, basestring):
                        self.response.body = body
                        contentlen = len(body)
                    else:
                        self.response.app_iter = body
                        contentlen = sum([len(d) for d in body])
                    self.response.content_length = contentlen

            return self.response(environ, start_response)
        finally:
            try:
                self.logger.flush(self.session, 20, self.request.remote_addr)
            except ValueError:
                # It's possible nothing was logged for this remote user
                pass

    def _get_query(self, form):
        session = self.session
        queryFactory = self.queryFactory
        qString = form.getvalue('query')
        rsid = form.getvalue('rsid', None)
        filter_ = form.getvalue('filter', '')
        withinContributor = form.getvalue('withinContributor', None)
        withinCollection = form.getvalue('withinCollection', None)
        if rsid:
            qString = self._fetch_query(session, rsid).toCQL()
        elif not qString:
            qString = generate_cqlQuery(form)
        if not isinstance(qString, unicode):
            qString = unicode(qString, 'utf-8')
        if filter_:
            if qString.strip('()'):
                qString = u'{0} and/relevant/proxinfo ({1})'.format(filter_,
                                                                    qString
                                                                    )
            else:
                qString = filter_

        if (withinCollection and withinCollection != 'allcollections'):
            if qString.strip(u'()'):
                qString = (u'(rec.collectionIdentifier exact "{0}") '
                           u'and/relevant/proxinfo '
                           u'({1})'.format(withinCollection,
                                           qString)
                           )
            else:
                qString = (u'rec.collectionIdentifier exact "{0}"'
                           u''.format(withinCollection))
        elif 'noComponents' in form:
            qString = (u'ead.istoplevel=1 and/relevant/proxinfo (%s)'
                       u'' % qString)

        if (withinContributor and withinContributor != 'allcontributors'):
            if qString.strip(u'()'):
                qString = (u'(vdb.identifier exact "{0}") '
                           u'and/relevant/proxinfo '
                           u'({1})'.format(withinContributor,
                                           qString)
                           )
            else:
                qString = (u'vdb.identifier exact "{0}"'
                           u''.format(withinContributor))

        if not qString.strip(u'()'):
            self._log(40, '*** Unable to generate CQL query')
            return self._render_template('fail/invalidQuery.html')

        try:
            return queryFactory.get_query(session,
                                          qString.encode('utf-8'),
                                          format="cql"
                                          )
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
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        if rsid and not 'filter' in form:
            try:
                rs = self._fetch_resultSet(session, rsid)
            except ObjectDoesNotExistException:
                self._log(40, '*** Invalid ResultSet identifier: %s' % rsid)
                return self._render_template(
                    'fail/invalidResultSet.html',
                    rsid=rsid
                )
        else:
            query = self._get_query(form)
            if not isinstance(query, (CQLClause, CQLTriple)):
                # Error message
                return query
            msg = (u'Searching CQL query: {0}'
                   u''.format(query.toCQL())
                   )
            self._log(20, msg.encode('utf-8'))
            rs = db.search(session, query)
            self._log(20, '{0} Hits'.format(len(rs)))
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
                # Check for ascending/descending sort
                # N.B. sort ascending=None is not the same as ascending=False
                # False => descending, None => do what's best for this spec
                ascending = None
                if spec.endswith('/ascending'):
                    spec = spec[:-len('/ascending')]
                    ascending = True
                elif spec.endswith('/descending'):
                    spec = spec[:-len('/descending')]
                    ascending = False

                # Check if the sort spec is an index
                protocolMap = db.get_path(session, 'protocolMap')
                try:
                    sortClause = self.queryFactory.get_query(
                        session,
                        '{0} exact ""'.format(spec)
                    )
                    # Fetch the index object from the database
                    index = protocolMap.resolveIndex(session, sortClause)
                except CQLDiagnostic:
                    index = None

                if index:
                    rs.order(session,
                             index,
                             ascending=ascending,
                             missing=0
                             )
                elif spec:
                    # Not an index, maybe a ResultSetItem attribute, or XPath?
                    # Pass the string to ResultSet to see what it makes of it
                    rs.order(session, spec)

        # Set resultSet cookie
        self._set_cookie('resultSet_id', rs.id)
        self._set_cookie('resultSet_startRecord', startRecord)
        self._set_cookie('resultSet_maximumRecords', maximumRecords)
        self._set_cookie('resultSet_sortBy', ','.join(sortBy))
        return rs

    def search(self, form):
        if not form:
            # Simply return the search form
            return [self._render_template('search.html')]
        self._log(10, 'search')
        sortBy = form.getlist('sortBy')
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        try:
            rs = self._searchAndSort(form)
        except ValueError as e:
            if str(e).startswith("0 documents"):
                return self._render_template('fail/noDocuments.html')
            self._log(30, str(e))
            raise

        if not isinstance(rs, ResultSet):
            # Error message
            return [rs]
        facets = self.facets(rs)
        if len(rs):
            return self._render_template('searchResults.html',
                                         resultSet=rs,
                                         filtered='filter' in form,
                                         sortBy=sortBy,
                                         maximumRecords=maximumRecords,
                                         startRecord=startRecord,
                                         facets=facets
                                         )
        else:
            return self._render_template('fail/noHits.html',
                                         query=rs.query
                                         )

    def similar(self, form):
        raise NotImplementedError()

    def facets(self, rs):
        session = self.session
        db = self.database
        pm = db.get_path(session, 'protocolMap')
        if not pm:
            db._cacheProtocolMaps(session)
            pm = db.protocolMaps.get('http://www.loc.gov/zing/srw/')
        try:
            nTerms = self.config.getint('facets', 'truncate')
        except ValueError:
            if self.config.getboolean('facets', 'truncate'):
                # Want truncation but value not specified - default 1000
                nTerms = 1000
            else:
                nTerms = 0

        facets = {}
        for cqlIdx, humanName in self.config.items('facets'):
            if not '.' in cqlIdx:
                # Setting, not index
                continue
            query = self.queryFactory.get_query(session,
                                                '{0}="*"'.format(cqlIdx),
                                                format='cql')
            idxObj = pm.resolveIndex(session, query)
            try:
                facets[(cqlIdx, humanName)] = idxObj.facets(session,
                                                            rs,
                                                            nTerms
                                                            )
            except:
                self._log(40, "Couldn't get facets from {0}".format(cqlIdx))
                facets[(cqlIdx, humanName)] = {}
        return facets

    def browse(self, form):
        if not form:
            # Simply return the search form
            return [self._render_template('browse.html')]
        self._log(10, 'browse')
        idx = form.getfirst('fieldidx1', None)
        # Quick Fix for Ticket 903
        if idx ==  u'c3.ead-idx-dateYear':
            idx = u'c3.idx-dateYear'
        ###
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
        self._log(10, 'subject')
        session = self.session
        db = self.database
        queryFactory = self.queryFactory
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        qString = form.getvalue('query')
        if not qString:
            qString = generate_cqlQuery(form)
            if not (len(qString)):
                self._log(40, 'Unable to generate CQL subject finder query')
                return self._render_template('fail/invalidSubjectQuery.html')
        try:
            query = queryFactory.get_query(session, qString, format='cql')
        except CQLDiagnostic:
            return self._render_template('fail/invalidSubjectQuery.html')
        session.database = 'db_ead_cluster'
        clusDb = session.server.get_object(session, session.database)
        rs = clusDb.search(session, query)
        if not len(rs):
            content = [self._render_template('fail/noSubjectHits.html',
                                             query=rs.query)
                       ]
        else:
            content = [self._render_template('subjectResults.html',
                                             resultSet=rs,
                                             maximumRecords=maximumRecords,
                                             startRecord=startRecord,
                                             )]
        session.database = 'db_ead'
        return content

    def summary(self, form):
        self._log(10, 'summary')
        session = self.session
        db = self.database
        sortBy = form.getlist('sortBy')
        maximumRecords = int(form.getvalue('maximumRecords', 20))
        startRecord = int(form.getvalue('startRecord', 1))
        hit = int(form.getvalue('hit', 0))
        rs = self._searchAndSort(form)
        if not isinstance(rs, ResultSet) and 'recid' in form:
            # Explicit request by Record identifier
            rec = self._fetch_record(session, form.getvalue('recid'))
            # Fetch most recent resultSet
            rsdata = self._fetch_mostRecentResultSet()
            rs, startRecord, maximumRecords, sortBy = rsdata
        elif not isinstance(rs, ResultSet):
            # Error message
            return [rs]
        else:
            try:
                rec = rs[hit].fetch_record(session)
            except ObjectDeletedException as e:
                # Record has been deleted!
                # 410 Gone status indicates that clients should purge the
                # resource. Probably not necessary, so return 404 status...
                self.response.status = 404
                # ...but a different user message
                return [self._render_template(
                    'fail/410.html',
                    resource=rs[hit].id
                )]
        # Save rec.id now
        recid = rec.id
        # Highlight search terms
        highlighter = db.get_object(session, 'highlightTxr')
        doc = highlighter.process_record(session, rec)
        xmlp = db.get_object(session, 'LxmlParser')
        rec = xmlp.process_document(session, doc)
        self._log(10, 'Search terms highlighted')
        summaryTxr = db.get_object(session, 'htmlSummaryTxr')
        page = self._render_template('summary.html',
                                     resultSet=rs,
                                     filtered='filter' in form,
                                     sortBy=sortBy,
                                     maximumRecords=maximumRecords,
                                     startRecord=startRecord,
                                     rec=rec,
                                     txr=summaryTxr
                                     )
        page = page.replace('SCRIPT',
                            self.defaultContext['SCRIPT'].encode('utf8'))
        page = page.replace('DATAURL',
                            self.defaultContext['DATAURL'].encode('utf8'))
        page = page.replace('RECID', recid)
        page = page.replace('LINKTOPARENT', '')
        return [page]

    def full(self, form):
        recid = form.getfirst('recid')
        url = self.request.relative_url('../data/' + recid)
        self.response.location = url
        self.response.status = "301 Moved Permanently"
        return ['<a href="{0}">{0}</a>'.format(url)]

    def toc(self, form):
        self._log(10, 'ToC only')
        recid = form.getfirst('recid')
        url = self.request.relative_url('../data/' + recid + '?page=toc')
        self.response.location = url
        self.response.status = "301 Moved Permanently"
        return ['<a href="{0}">{0}</a>'.format(url)]

    def email(self, form):
        self._log(10, 'email')
        recid = form.getfirst('recid')
        # Fetch most recent resultSet
        rsdata = self._fetch_mostRecentResultSet()
        rs, startRecord, maximumRecords, sortBy = rsdata
        if 'address' not in form:
            self._log(10, 'requesting address')
            # Simply return the search form
            return [self._render_template('email.html',
                                          recid=recid,
                                          resultSet=rs,
                                          startRecord=startRecord,
                                          maximumRecords=maximumRecords,
                                          sortBy=sortBy)]
        address = form.getfirst('address')
        rec = self._fetch_record(session, recid)
        docTxt = u'\n'.join([textwrap.fill(rawline, 78) + u'\n'
                             for rawline
                             in self._textFromRecord(rec).split(u'\n')
                             ]).encode('utf-8')
        try:
            from_addy = self.config.get('email', 'from')
        except:
            from_addy = '{0}@{1}'.format(
                self.config.get('email', 'username'),
                self.request.host
            )
        mimemsg = MIMEMultipart.MIMEMultipart()
        mimemsg['Subject'] = 'Requested Finding Aid'
        mimemsg['From'] = from_addy
        mimemsg['To'] = address

        # Guarantees the message ends in a newline
        mimemsg.epilogue = '\n'
        msg = MIMEText.MIMEText(docTxt)
        mimemsg.attach(msg)

        # send message
        s = smtplib.SMTP()
        email_host = self.config.get('email', 'host')
        email_port = self.config.getint('email', 'port')
        try:
            s.connect(host=email_host, port=email_port)
        except:
            self._log(40,
                      'Failed to connect to email server: {0}:{1}'.format(
                          email_host,
                          email_port
                      ))
            return [self._render_template('fail/emailServer.html',
                                          host=email_host,
                                          port=email_port,
                                          resultSet=rs,
                                          startRecord=startRecord,
                                          maximumRecords=maximumRecords,
                                          sortBy=sortBy
                                          )]

        s.sendmail(from_addy, address, mimemsg.as_string())
        s.quit()
        self._log(20, 'Record {0} emailed to {1}'.format(recid, address))
        return [self._render_template('emailSent.html',
                                      recid=recid,
                                      address=address,
                                      resultSet=rs,
                                      startRecord=startRecord,
                                      maximumRecords=maximumRecords,
                                      sortBy=sortBy
                                      )]

    def system(self, form):
        return self._render_template('system.html')


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


application = EADSearchWsgiApplication(config, session, db)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == "__main__":
    sys.exit(main())
