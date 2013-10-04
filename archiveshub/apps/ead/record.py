"""EAD Record Resolver WSGI Application."""
from __future__ import with_statement

import sys
import os
import re
import webbrowser
import mimetypes
import textwrap
import time
import urllib
import urllib2

from collections import OrderedDict
from random import randint
from string import Template as StrTemplate
import itertools

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

# site-package
from lxml import etree
from lxml import html as lxmlhtml

from cheshire3.exceptions import (
    FileDoesNotExistException,
    ObjectDoesNotExistException
)

# Cheshire3 for Archives Imports
from archiveshub.deploy.utils import WSGIAppArgumentParser
from archiveshub.apps.ead.base import EADWsgiApplication
from archiveshub.apps.ead.base import listCollections
from archiveshub.apps.ead.base import dataFromRecordXPaths, emailFromArchonCode
from archiveshub.apps.ead.base import backwalkComponentTitles
from archiveshub.apps.ead.base import config, session, db


class EADRecordWsgiApplication(EADWsgiApplication):

    def __init__(self, session, database, config):
        # Constructor method
        super(EADRecordWsgiApplication, self).__init__(session,
                                                       database,
                                                       config)
        # Fetch Logger
        self.logger = self.database.get_object(session,
                                               'recordTransactionLogger'
                                               )
        self.mimetypeHash = mtHash = OrderedDict([
            ('text/html', self.html),
            ('application/xml', self.xml),
            ('text/xml', self.xml),
            ('text/plain', self.text)
        ])

    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        try:
            self._setUp(environ)
            session = self.session
            path = self.request.path_info.strip('/')
            if path == "environ":
                if self.request.remote_addr in ['127.0.0.1']:
                    self.response.content_type = 'text/plain'
                    itertools.imap(repr, )
                    self.response.app_iter = [
                        repr(i) + '\n'
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
                mimetype = self.request.accept.best_match(
                    self.mimetypeHash.keys(),
                    "text/html"
                )
                encoding = None

            # Fetch the Record
            try:
                rec = self._fetch_record(session, recid)
            except (IndexError, FileDoesNotExistException) as e:
                # IndexError can occur due to a 'feature' (bug) in Cheshire3
                # which assumes that all search terms will be a string of 1 or
                # more characters
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
        finally:
            try:
                self.logger.flush(self.session, 20, self.request.remote_addr)
            except ValueError:
                # It's possible nothing was logged for this remote user
                pass

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

    def _GA(self):
        """Track using Google Analytics - intended for non-HTML files.

        Ported from code at:
        http://www.mjdigital.co.uk/blog
            /track-xml-or-server-side-files-using-google-analytics/

        #01    # Track using Google Analytics
        // Enter your unique GA Urchin ID (utmac)
        #02    $ga_uid='UA-XXXXXXX-X';
        // Enter your domain name/host name (utmhn)
        #03    $ga_domain='mydomain.com';
        // Creates a random request number (utmn)
        #04    $ga_randNum=rand(1000000000,9999999999);
        // Creates a random cookie number (cookie)
        #05    $ga_cookie=rand(10000000,99999999);
        // Creates a random number below 2147483647 (random)
        #06    $ga_rand=rand(1000000000,2147483647);
        // Current Timestamp
        #07    $ga_today=time();
        // Referrer url
        #08    $ga_referrer=$_SERVER['HTTP_REFERER'];
        #09
        // Enter any variable data you want to pass to GA or leave blank
        #10    $ga_userVar='';
        // Enter the page address you want to track
        #11    $ga_hitPage='/blog/sitemap.xml';
        #12
        #13    $gaURL='http://www.google-analytics.com/__utm.gif?utmwv=1&
        utmn='.$ga_randNum.'&utmsr=-&utmsc=-&utmul=-&utmje=0&utmfl=-&utmdt=-&
        utmhn='.$ga_domain.'&utmr='.$ga_referrer.'&utmp='.$ga_hitPage.'&
        utmac='.$ga_uid.'&utmcc=__utma%3D'.$ga_cookie.'.'.$ga_rand.'.'.
        $ga_today.'.'.$ga_today.'.'.$ga_today.'.2%3B%2B__utmb%3D'.$ga_cookie.
        '%3B%2B__utmc%3D'.$ga_cookie.'%3B%2B__utmz%3D'.$ga_cookie.'.'.
        $ga_today.'.2.2.utmccn%3D(direct)%7Cutmcsr%3D(direct)%7Cutmcmd%3D(none)
        %3B%2B__utmv%3D'.$ga_cookie.'.'.$ga_userVar.'%3B';
        #14
        // open the xml file
        #15    $handle = @f open($gaURL, "r");
        // get the XML data
        #16    $fget = @f gets($handle);
        // close the xml file
        #17    @f close($handle);
        #18
        // set the document content type for the output
        #19    header('Content-Type: text/xml;');
        // get the actual file to output
        #20    $xml = @file_get_contents('sitemap.xml');
        // output the data
        #21    echo $xml;
        """
        # Enter your unique GA Urchin ID (utmac)
        if self.request.host_port == 80:
            # Live Hub
            ga_uid = 'UA-2834703-1'
        else:
            # Test / Beta / Development; use alternative tracking ID
            ga_uid = 'UA-2834703-4'

        # Enter your domain name/host name (utmhn)
        ga_domain = 'archiveshub.ac.uk'
        # Creates a random request number (utmn)
        ga_randNum = randint(1000000000, 9999999999)
        # Creates a random cookie number (cookie)
        ga_cookie = randint(10000000, 99999999)
        # Creates a random number below 2147483647 (random)
        ga_rand = randint(1000000000, 2147483647)
        # Current Timestamp
        ga_today = time.time()
        # Enter any variable data you want to pass to GA or leave blank
        ga_referrer = self.request.referer
        if self.request.urlvars:
            ga_userVar = urllib.quote(self.request.urlvars)
        else:
            ga_userVar = ''
        # Enter the page address you want to track
        ga_hitPage = self.request.path
        ga_url_tmpl = StrTemplate(
            'http://www.google-analytics.com/__utm.gif?'
            'utmwv=1&utmsr=-&utmsc=-&utmul=-&utmje=0&utmfl=-&utmdt=-&'
            'utmn=${ga_randNum}&'
            'utmhn=${ga_domain}&'
            'utmr=${ga_referrer}&'
            'utmp=${ga_hitPage}&'
            'utmac=${ga_uid}&'
            'utmcc=__utma%3D${ga_cookie}.${ga_rand}.${ga_today}.${ga_today}.'
            '${ga_today}.2%3B%2B__utmb%3D${ga_cookie}%3B%2B__utmc%3D'
            '${ga_cookie}%3B%2B__utmz%3D${ga_cookie}.${ga_today}.2.2.utmccn%3D'
            '(direct)%7Cutmcsr%3D(direct)%7Cutmcmd%3D(none)%3B%2B__utmv%3D'
            '${ga_cookie}.${ga_userVar}%3B'
        )
        ga_url = ga_url_tmpl.substitute(ga_uid=ga_uid,
                                        ga_domain=ga_domain,
                                        ga_randNum=ga_randNum,
                                        ga_cookie=ga_cookie,
                                        ga_rand=ga_rand,
                                        ga_today=ga_today,
                                        ga_referrer=ga_referrer,
                                        ga_userVar=ga_userVar,
                                        ga_hitPage=ga_hitPage)
        # Try to pass the original User-Agent through to GA
        headers = {
            'User-Agent': self.request.headers.get('User-Agent',
                                                   "AH-Record-Resolver"
                                                   )
        }
        # Open the tracking request URL
        gareq = urllib2.Request(ga_url, None, headers)
        urlfh = urllib2.urlopen(gareq)
        try:
            # Read the data
            urlfh.read()
        finally:
            # Close the remote file
            urlfh.close()
        # File will actually be returned by the calling method, so we're done!
        return

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
            path = os.path.join(
                self.config.get('cache', 'html_cache_path'),
                '{0}.{1}.html'.format(recid.replace('/', '_'), pagenum)
            )
            try:
                page = unicode(open(path, 'rb').read(), 'utf-8')
            except IOError:
                # Page 1 exists, but not requested page
                # Return invalid page number
                return self._render_template('fail/invalidPageNumber.html',
                                             recid=recid,
                                             pagenum=pagenum)
            self._log(10, 'Retrieved {0} from cache'.format(path))
            # Retrieve toc
            tocpath = os.path.join(
                self.config.get('cache', 'html_cache_path'),
                '{0}.toc.html'.format(recid.replace('/', '_'))
            )
            try:
                toc = unicode(open(tocpath, 'rb').read(), 'utf-8')
            except IOError:
                # No ToC file
                toc = None

        else:
            # Transform the Record
            doc_uc = self._transformRecord(rec, 'htmlFullSplitTxr')
            self._log(10, 'HTML generated by splitting XSLT')
            # Add in the enquiries email link
            archon_code = dataFromRecordXPaths(
                session,
                rec,
                ['/*/*/did/unitid/@repositorycode',
                 '/ead/eadheader/eadid/@mainagencycode'
                 ]
            )
            email_address = emailFromArchonCode(archon_code)
            doc_uc = doc_uc.replace(
                u'contributor_{0}@example.com'.format(archon_code),
                email_address
            )
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
            # Context hierarchy?
            try:
                rec.process_xpath(session, '/c3component/@parent')[0]
            except IndexError:
                # Collection level
                pass
            else:
                # OK, must be a component record
                titles = backwalkComponentTitles(session, rec)
                template = self.templateLookup.get_template('hierarchy.html')
                func = template.get_def("hierarchyList")
                d = self.defaultContext.copy()
                d.update(titles=titles[:-1])
                divs.insert(0, lxmlhtml.fragment_fromstring(func.render(**d)))

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
                    pageBuffer.write(etree.tostring(div,
                                                    pretty_print=True,
                                                    method="html"
                                                    )
                                     )
            # Read final page
            pages.append(self._readBuffer(pageBuffer))
            # Output pages to cache
            for idx, page in enumerate(pages):
                # Template for page navigation if necessary
                page = self._render_template('detailedPage.html',
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
                                             recid=recid,
                                             pagenum=pagenum,
                                             maxPages=len(pages))
        if not toc:
            # Fetch most recent resultSet
            try:
                rsdata = self._fetch_mostRecentResultSet()
            except ObjectDoesNotExistException:
                return self._render_template('detailedWithToC.html',
                                             recid=recid,
                                             toc=toc,
                                             page=page,
                                             )
            else:
                rs, startRecord, maximumRecords, sortBy = rsdata
                return self._render_template('detailed.html',
                                             recid=recid,
                                             page=page,
                                             resultSet=rs,
                                             startRecord=startRecord,
                                             maximumRecords=maximumRecords,
                                             sortBy=sortBy
                                             )
        else:
            return self._render_template('detailedWithToC.html',
                                         recid=recid,
                                         toc=toc,
                                         page=page,
                                         )

    def index(self, mimetype, form):
        # Scan the rec.identifier index
        # Return a display appropriate for the requested mimetype
        collections = listCollections(self.session)
        if str(mimetype).endswith('/xml'):
            raise NotImplementedError()
        elif str(mimetype) == 'text/plain':
            raise NotImplementedError()
        else:
            return self._render_template('dataIndex.html',
                                         collections=collections
                                         )

    def text(self, rec, form):
        # Track in Google Analytics
        self._GA()
        txt = self._textFromRecord(rec)
        # Wrap long lines
        return u'\n'.join([textwrap.fill(rawline, 78)
                           for rawline
                           in txt.split(u'\n')
                           ]).encode('utf-8')

    def toc(self, rec, form):
        path = os.path.join(
            self.config.get('cache', 'html_cache_path'),
            '{0}.toc.html'.format(rec.id.replace('/', '_'))
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
        # Track in Google Analytics
        self._GA()
        # Fix mimetype modules incorrect text/xml
        self.response.content_type = 'application/xml'
        session = self.session
        db = self.database
        # Check for requested schema, or revert to default, currently 'ead'
        schema = form.getvalue('schema', 'ead')
        if schema in ['ead-raw', 'ead-hub'] or 'hub' in form:
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
