"""EAD Search WSGI Application."""

import sys
import os
import socket
import webbrowser
import textwrap

from cgi import FieldStorage
from argparse import ArgumentParser

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer
from cheshire3.internal import cheshire3Version, cheshire3Root

from base import *


class EADSearchWsgiApplication(EADWsgiApplication):
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        # Prepare application to handle a new request
        self._setUp(environ)
        # Check for static content request
        path = environ.get('PATH_INFO', '').strip('/')
        if path.startswith(('css', 'img', 'js')):
            content = self._static_content(path)
            if not content:
                start_response("404 NOT FOUND", self.response_headers)
            else:
                start_response("200 OK", self.response_headers)
            return content
            
        fields = FieldStorage(fp=environ['wsgi.input'], environ=environ)
        # Normalize form
        form = {}
        for qp in fields.list:
            if qp.value.isdigit():
                form[qp.name] = int(qp.value)
            else:
                form[qp.name] = qp.value
        operation = form.get('operation', None)
        if operation is None:
            # Filename based?
            operation = os.path.splitext(path.split('/')[-1])[0]
        
        # Check operation and act accordingly
        if not operation:
            content = self._render_template('search.html')
        elif operation == 'resolve':
            content = self.subject(form)
        else:
            try:
                fn = getattr(self, operation)
            except AttributeError:
                # Invalid operation selected
                self.htmlTitle.append('Error')
                content = ('<p class="error">',
                           'An invalid operation was attempted. ',
                           'Valid operations are:<br/>',
                           'search, browse, resolve, summary, full, toc, email',
                           '</p>'
                           )
            else:
                # Simple method of self
                try:
                    content = fn(form)
                except:
                    content = self._handle_error()
        response_headers = [('Content-Type',
                             'text/html'),
                            ('Content-Length',
                             str(sum([len(d) for d in content])))
                            ]
        start_response("200 OK", response_headers)
        return content

    def search(self, form):
        raise NotImplementedError()

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