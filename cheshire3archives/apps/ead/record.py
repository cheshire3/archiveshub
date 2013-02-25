"""EAD Record Resolver WSGI Application."""

import sys
import os
import socket
import webbrowser
import mimetypes
import textwrap

from cgi import FieldStorage
from argparse import ArgumentParser
from foresite import conneg

from base import *


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
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        self._setUp(environ)
        path = environ.get('PATH_INFO', '').strip('/')
        if path == "environ":
            self.response_headers.append(('Content-Type', 'text/plain'))
            start_response('200 OK', self.response_headers)
            return [repr(i) + '\n' for i in environ.iteritems()]

        # Parse request to determine record, Internet (MIME) Type etc.
        recid, mimetype, encoding, args = self._parse_recSpec(path)
        # Content negotiation if not specified by file extension
        if mimetype is None:
            mtrequested = environ.get('HTTP_ACCEPT', 'text/html')
            mtc = conneg.parse(mtrequested)
            mimetype = conneg.best(mtc, self.mimetypeList)
            encoding = None
        
        # Fetch the Record
        try:
            rec = self._fetch_record(session, recid)
        except c3errors.FileDoesNotExistException as e:
            # Still could not be found - 404!
            start_response("404 Not Found", self.response_headers)
            return []
        fn = self.mimetypeHash.get(str(mimetype), getattr(self, 'html'))
        content = fn(rec, args)
        print self.response_headers
#        try:
#            content = fn(rec, args)
#        except:
#            content = self._handle_error()
#            start_response("500 Not Found", response_headers)
#            return content
        start_response("200 OK", self.response_headers)
        return content

    def _parse_recSpec(self, path_info):
        recid = path_info
        mType, encoding = mimetypes.guess_type(path_info)
        if mType is not None:
            # There is a filename extension to strip off
            recid, ext = os.path.splitext(recid)
        fields = FieldStorage(fp=self.environ['wsgi.input'], environ=self.environ)
        # Normalize form
        form = {}
        for qp in fields.list:
            if qp.value.isdigit():
                form[qp.name] = int(qp.value)
            else:
                form[qp.name] = qp.value
        return recid, mType, encoding, form

    def html(self, rec, form):
        self.response_headers.append(('Content-Type', 'text/html'))
        raise NotImplementedError()

    def xml(self, rec, form):
        session = self.session
        db = self.database
        self.response_headers.append(('Content-Type', 'application/xml'))
        # Check for requested schema, or revert to default, currently 'ead'
        schema = form.get('schema', 'ead')
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

    def text(self, rec, form):
        self.response_headers.append(('Content-Type', 'text/plain'))
        for rawline in self._textFromRecord(rec).split('\n'):
            yield textwrap.fill(rawline, 78) + '\n'


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
argparser = ArgumentParser(description=__doc__.splitlines()[0])
# Find default hostname
try:
    hostname = socket.gethostname()
except:
    hostname = 'localhost'

argparser.add_argument('--hostname', type=str,
                       action='store', dest='hostname',
                       default=hostname, metavar='HOSTNAME',
                       help=("name of host to listen on. default derived by "
                             "inspection of local system"))
argparser.add_argument('-p', '--port', type=int,
                       action='store', dest='port',
                       default=8008, metavar='PORT',
                       help="number of port to listen on. default: 8008")
argparser.add_argument('--no-browser',
                       action='store_false', dest='browser',
                       default=True,
                       help=("don't open a browser window/tab containing the "
                             "app. useful if you want to deploy the app for "
                             "other users"
                             )
                       )


if __name__ == "__main__":
    sys.exit(main())