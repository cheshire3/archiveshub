"""EAD Record Resolver WSGI Application."""

import sys
import os
import re
import socket
import webbrowser
import mimetypes
import textwrap

from cgi import FieldStorage
from argparse import ArgumentParser
from foresite import conneg
from lxml import etree
from lxml import html as lxmlhtml

# Cheshire3 for Archives Imports
from cheshire3archives.commands.utils import WSGIAppArgumentParser
from cheshire3archives.apps.ead.base import *


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
        # Set the base URL of this family of apps
        base = re.sub('/data$', '', self.script)
        self.globalReplacements['BASE'] = base
        self.config.set('icons', 'base-url', '{0}/img'.format(base))
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        self._setUp(environ)
        session = self.session
        path = environ.get('PATH_INFO', '').strip('/')
        if path == "environ":
            self.response_headers.append(('Content-Type', 'text/plain'))
            start_response('200 OK', self.response_headers)
            return [repr(i) + '\n' for i in environ.iteritems()]

        # Parse request to determine record, Internet (MIME) Type etc.
        recid, mimetype, encoding, form = self._parse_recSpec(path)
        # Content negotiation if not specified by file extension
        if mimetype is None:
            mtrequested = environ.get('HTTP_ACCEPT', 'text/html')
            mtc = conneg.parse(mtrequested)
            mimetype = conneg.best(mtc, self.mimetypeList)
            encoding = None
        
        # Fetch the Record
        try:
            rec = self._fetch_record(session, recid)
        except (IndexError, c3errors.FileDoesNotExistException) as e:
            # IndexError can occur due to a 'feature' (bug) in Cheshire3 which
            # assumes that all search terms will be a string of 1 or more
            # characters
            if not recid or recid == 'index':
                content = self.index(mimetype, form)
            else:
                # Record specified but could not be found - 404!
                start_response("404 Not Found", self.response_headers)
                return []
        else:
            self._log(10, 'Retrieved record "{0}"'.format(recid))
            fn = self.mimetypeHash.get(str(mimetype), getattr(self, 'html'))
            content = fn(rec, form)
        start_response("200 OK", self.response_headers)
        return content

    def _parse_recSpec(self, path_info):
        recid = path_info
        mType, encoding = mimetypes.guess_type(path_info)
        if mType is not None:
            # There is a filename extension to strip off
            recid, ext = os.path.splitext(recid)
        form = FieldStorage(fp=self.environ['wsgi.input'],
                              environ=self.environ)
        return recid, mType, encoding, form

    def html(self, rec, form):
        self.response_headers.append(('Content-Type', 'text/html'))
        session = self.session
        db = self.database
        recid = rec.id
        pagenum = int(form.getfirst('page', 1))
        try:
            parentId = rec.process_xpath(session, '/c3component/@parent')[0]
        except IndexError:
            isComponent = False
            parentId = recid
            parentLink = ''
        else:
            # OK, must be a component record
            isComponent = True
        path = os.path.join(self.config.get('cache', 'html_cache_path'),
                            recid.replace('/', '-') +
                            '.%d.html' % (pagenum)
                            )
        self._log(10, 'Full-text requested for {0}: {1}'
                  ''.format(['record', 'component'][int(isComponent)], recid)
                  )
        try:
            return open(path)
        except IOError:
            txr = db.get_object(session, 'htmlFullSplitTxr') 
            doc = txr.process_record(session, rec)
            divs = lxmlhtml.fragments_fromstring(doc.get_raw(session).decode('utf-8'))
            assert len(divs) == 2
            toc = '\n'.join([etree.tostring(el) for el in divs[1].iterchildren()])
            page = ''.join([etree.tostring(el) for el in divs[0][0].iterchildren()])
            return [self._render_template('detailedToc.html',
                                          session=session,
                                          toc=toc,
                                          page=page
                                          )]
        else:
            self._log(10, 'Retrieved from cache')

    def index(self, mimetype, form):
        # Scan the rec.identifier index
        # Return a display appropriate for the requested mimetype
        collections = listCollections(self.session)
        if mimetype.endswith('/xml'):
            raise NotImplementedError()
        elif mimetype == 'text/plain':
            raise NotImplementedError()
        else:
            return [self._render_template('dataIndex.html',
                                          collections=collections
                                          )]

    def text(self, rec, form):
        self.response_headers.append(('Content-Type', 'text/plain'))
        for rawline in self._textFromRecord(rec).split('\n'):
            yield textwrap.fill(rawline, 78) + '\n'

    def xml(self, rec, form):
        session = self.session
        db = self.database
        self.response_headers.append(('Content-Type', 'application/xml'))
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
        return [doc.get_raw(session)]


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