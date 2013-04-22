"""EAD Record Resolver WSGI Application."""

import sys
import os
import re
import webbrowser
import mimetypes
import textwrap

from foresite import conneg
from lxml import etree
from lxml import html as lxmlhtml

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

from cheshire3.exceptions import FileDoesNotExistException

# Cheshire3 for Archives Imports
from archiveshub.commands.utils import WSGIAppArgumentParser
from archiveshub.apps.ead.base import EADWsgiApplication 
from archiveshub.apps.ead.base import listCollections
from archiveshub.apps.ead.base import config, session, db


class EADRecordWsgiApplication(EADWsgiApplication):
    
    def __init__(self, session, database, config):
        # Constructor method
        super(EADRecordWsgiApplication, self).__init__(session,
                                                       database,
                                                       config)
        self.mimetypeHash = mtHash = {'text/html': self.html,
                                      'text/plain': self.text,
                                      'application/xml': self.xml
                                     }
        # Fix for mimetypes module bug
        mtHash.update({'text/xml': self.xml})
        self.mimetypeList = conneg.parse(', '.join(mtHash.keys()))

    def _setUp(self, environ):
        super(EADRecordWsgiApplication, self)._setUp(environ)
        # Set the URL of the data resolver (i.e. self)
        self.defaultContext['DATAURL'] = self.request.script_name
        # Set the base URL for this family of apps
        base = self.request.relative_url('../search').rstrip(u'/')
        # Set SCRIPT to be base search app, rather than data app
        self.defaultContext['SCRIPT'] = base
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        self._setUp(environ)
        session = self.session
        path = self.request.path_info.strip('/')
        if path == "environ":
            if self.request.remote_addr in ['127.0.0.1']:
                self.response.content_type = 'text/plain'
                self.response.app_iter = [repr(i) + '\n'
                                         for i
                                         in self.request.environ.iteritems()
                                         ]
            else:
                self.response.status = 403
            return self.response(environ, start_response)

        # Parse request to determine record, Internet (MIME) Type etc.
        recid, mimetype, encoding = self._parse_recSpec(path)
        form = self._get_params()
        # Content negotiation if not specified by file extension
        if mimetype is None:
            mtrequested = environ.get('HTTP_ACCEPT', 'text/html')
            mtc = conneg.parse(mtrequested)
            mimetype = conneg.best(mtc, self.mimetypeList)
            encoding = None

        # Fetch the Record
        try:
            rec = self._fetch_record(session, recid)
        except (IndexError, FileDoesNotExistException) as e:
            # IndexError can occur due to a 'feature' (bug) in Cheshire3 which
            # assumes that all search terms will be a string of 1 or more
            # characters
            if not recid or recid == 'index':
                self.response.app_iter = self.index(mimetype, form)
            else:
                # Record specified but could not be found - 404!
                self.response.status = 404
                self.response.body = self._render_template('fail/404.html',
                                                           resource=recid
                                                           )
        else:
            self._log(10, 'Retrieved record "{0}"'.format(recid))
            fn = self.mimetypeHash.get(str(mimetype))
            if fn is None:
                # Unsupported mimetype - may be supported in future
                self.response.status = 303
                self.response.location = "{0}.html".format(recid)
                self.response.body = ('<a href="{0}">{0}</a>'
                                      ''.format(self.response.location))
            else:
                # Set Content-Type now to allow method to over-ride
                self.response.content_type = str(mimetype)
                self.response.body = fn(rec, form)
        
        return self.response(environ, start_response)

    def _parse_recSpec(self, path_info):
        recid = path_info
        mType, encoding = mimetypes.guess_type(path_info)
        if mType is not None:
            # There is a filename extension to strip off
            recid, ext = os.path.splitext(recid)
        return recid, mType, encoding

    def _readBuffer(self, buffer_):
        # Read and close the given file-like page buffer, return the content
        buffer_.seek(0)
        data = buffer_.read()
        buffer_.close()
        return data

    def _outputPage(self, recid, page_number, page, anchorPageHash={}):
        # Make some global replacements
        page = page.replace(u'RECID', unicode(recid))
        
        page = page.replace(u'SCRIPT', self.defaultContext['SCRIPT'])
        page = page.replace(u'DATAURL', self.defaultContext['DATAURL'])
        # Resolve anchors
        for anchorName, anchorPage in anchorPageHash.iteritems():
            page = page.replace(u'PAGE#{0}"'.format(anchorName),
                                u'{0}/{1}.html?page={2}#{3}"'
                                u''.format(self.defaultContext['DATAURL'],
                                           recid,
                                           anchorPage,
                                           anchorName)
                                )
        # All links should now have been resolved to their correct pages
        # Revert any remaining ones to the first page
        page = page.replace(u'PAGE#"',
                            u'{0}/{1}.html?page=1#"'
                            u''.format(self.defaultContext['DATAURL'],
                                       recid)
                            )
        # Get path of file
        path = os.path.join(self.config.get('cache', 'html_cache_path'),
                            '{0}.{1}.html'.format(recid.replace('/', '-'),
                                                  page_number)
                            )
        with open(path, 'wb') as fh:
            fh.write(page.encode('utf-8'))
        return page

    def html(self, rec, form):
        session = self.session
        db = self.database
        recid = rec.id
        pagenum = form.getfirst('page', 1)
        if pagenum == 'toc':
            # Redirect to self.toc
            return self.toc(rec, form)
        try:
            pagenum = int(pagenum)
        except ValueError:
            return self._render_template('fail/incorrectValueType.html',
                                         key="page",
                                         value=form.getfirst('page'),
                                         expected=('an integer (whole number)'
                                                   ' or "toc"')
                                         )
        try:
            parentId = rec.process_xpath(session, '/c3component/@parent')[0]
        except IndexError:
            isComponent = False
            parentId = recid
            parentLink = ''
        else:
            # OK, must be a component record
            isComponent = True
        self._log(10, 'Full-text requested for {0}: {1}'
                  ''.format(['record', 'component'][int(isComponent)], recid)
                  )
        path = os.path.join(self.config.get('cache', 'html_cache_path'),
                            '{0}.1.html'.format(recid.replace('/', '_'))
                            )
        if os.path.exists(path):
            path = os.path.join(self.config.get('cache', 'html_cache_path'),
                                '{0}.{1}.html'.format(recid.replace('/', '_'),
                                                      pagenum
                                                      )
            )
            try:
                page = unicode(open(path, 'rb').read(), 'utf-8')
            except IOError:
                # Page 1 exists, but not requested page
                # Return invalid page number
                return self._render_template('fail/invalidPageNumber.html',
                                             session=session,
                                             recid=recid,
                                             pagenum=pagenum)
            self._log(10, 'Retrieved {0} from cache'.format(path))
            # Retrieve toc
            tocpath = os.path.join(self.config.get('cache', 'html_cache_path'),
                                   '{0}.toc.html'.format(
                                        recid.replace('/', '_')
                                   )
            )
            try:
                toc = unicode(open(tocpath, 'rb').read(), 'utf-8')
            except IOError:
                # No ToC file
                toc = None
                
        else:
            # Transform the Record
            doc_uc = self._transformRecord(rec, 'htmlFullSplitTxr')
            # Parse HTML fragments
            divs = lxmlhtml.fragments_fromstring(doc_uc)
            # Get Table of Contents
            tocdiv = divs.pop(0)
            if len(tocdiv):
                toc = etree.tounicode(tocdiv,
                                      pretty_print=True,
                                      method="html")
            else:
                toc = None
            # Assemble real pages
            # Start a StringIO
            pageBuffer = StringIO()
            # Set page size bound
            pageSizeBound = self.config.getint('cache', 'html_file_size_kb')
            # Allow space for wrapper template
            pageSizeBound = pageSizeBound - 1
            pages = []
            anchorPageHash = {}
            for div in divs:
                # Convert to HTML (from XHTML)
                lxmlhtml.xhtml_to_html(div)
                if (pageBuffer.tell() > pageSizeBound * 1024):
                    # Finish current page
                    # Add completed page to final pages
                    pages.append(self._readBuffer(pageBuffer))
                    # Start new pageBuffer
                    pageBuffer = StringIO()
                elif isinstance(div, etree.ElementBase):
                    # Only include elements
                    # Find all internal anchors
                    anchors = div.xpath('descendant-or-self::a/@name')
                    anchorPageHash.update(dict([(name, len(pages) + 1) for
                                                name in anchors
                                                ])
                                          )
                    pageBuffer.write(etree.tounicode(div,
                                                     pretty_print=True,
                                                     method="html")
                                     )
            # Read final page
            pages.append(self._readBuffer(pageBuffer))
            # Output pages to cache
            for idx, page in enumerate(pages):
                # Template for page navigation if necessary
                page = self._render_template('detailedPage.html',
                                             session=session,
                                             recid=recid,
                                             page=page,
                                             pagenum=idx + 1,
                                             maxPages=len(pages)
                                             )
                # Keep as unicode (decode early, encode late)
                page = page.decode('utf-8')
                # Make global replacements and output to file
                page = self._outputPage(recid,
                                        idx + 1,
                                        page,
                                        anchorPageHash)
                # Replace page in pages
                pages[idx] = page
            if toc is not None:
                # Output ToC to cache
                toc = self._outputPage(recid, "toc", toc, anchorPageHash)
            # Return requested page
            try:
                page = pages[pagenum - 1]
            except IndexError:
                # Return invalid page number
                return self._render_template('fail/invalidPageNumber.html',
                                             session=session,
                                             recid=recid,
                                             pagenum=pagenum,
                                             maxPages=len(pages))
        if not toc:
            # Fetch most recent resultSet
            rsdata = self._fetch_mostRecentResultSet()
            rs, startRecord, maximumRecords, sortBy = rsdata
            return self._render_template('detailed.html',
                                         session=session,
                                         recid=recid,
                                         page=page,
                                         resultSet=rs,
                                         startRecord=startRecord,
                                         maximumRecords=maximumRecords,
                                         sortBy=sortBy
                                         )
        else:
            return self._render_template('detailedWithToC.html',
                                         session=session,
                                         recid=recid,
                                         toc=toc,
                                         page=page,
                                         )

    def index(self, mimetype, form):
        # Scan the rec.identifier index
        # Return a display appropriate for the requested mimetype
        collections = listCollections(self.session)
        if mimetype.endswith('/xml'):
            raise NotImplementedError()
        elif mimetype == 'text/plain':
            raise NotImplementedError()
        else:
            return self._render_template('dataIndex.html',
                                         collections=collections
                                         )

    def text(self, rec, form):
        txt = self._textFromRecord(rec)
        # Wrap long lines
        return u'\n'.join([textwrap.fill(rawline, 78)
                           for rawline
                           in txt.split(u'\n')
                           ]).encode('utf-8')

    def toc(self, rec, form):
        path = os.path.join(self.config.get('cache', 'html_cache_path'),
                            '{0}.toc.html'.format(
                            rec.id.replace('/', '_')
                            )
        )
        try:
            doc_uc = unicode(open(path, 'rb').read(), 'utf-8')
        except IOError:
            # No ToC file
            doc_uc = self._transformRecord(rec, 'htmlContentsTxr')
        return self._render_template('toc.html',
                                     recid=rec.id,
                                     toc=doc_uc
                                     )

    def xml(self, rec, form):
        # Fix mimetype modules incorrect text/xml
        self.response.content_type = 'application/xml'
        session = self.session
        db = self.database
        # Check for requested schema, or revert to default, currently 'ead'
        schema = form.getvalue('schema', 'ead')
        if schema == 'ead-raw':
            txr = db.get_object(session, 'XmlTransformer')
        elif schema == 'ead':
            txr = db.get_object(session, 'dataOutgoingTxr')
        else:
            # Find transformer from SRU ProtocolMap
            db._cacheProtocolMaps(session)
            map_ = db.protocolMaps.get('http://www.loc.gov/zing/srw/', None)
            recordMap = map_.recordNamespaces
            if (schema in recordMap):
                schema = recordMap[schema]
            if (schema and not (schema in map_.recordNamespaces.values())):
                raise ValueError('Unknown schema: {0}'.format(schema))
            txr = map_.transformerHash.get(schema, None)
        doc = txr.process_record(session, rec)
        return doc.get_raw(session)


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


application = EADRecordWsgiApplication(session, db, config)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == "__main__":
    sys.exit(main())