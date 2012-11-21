
import sys
import os

from cgi import FieldStorage

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer
from cheshire3.internal import cheshire3Version, cheshire3Root

# Local imports
from ead import EADWsgiApplication
from localConfig import *


class EADSearchWsgiApplication(EADWsgiApplication):
    
    def __call__(self, environ, start_response):
        path = environ.get('PATH_INFO', '').strip('/')
        self.globalReplacements.update({'SCRIPT': path,
                                        '%SCRIPT%': path
                                        }
                                       )
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
        if operation == 'resolve':
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
                content = fn(form)
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


def main():
    """Start up a simple app server to serve the SRU application."""
    from wsgiref.simple_server import make_server
    try:
        host = sys.argv[1]
    except IndexError:
        try:
            import socket
            host = socket.gethostname()
        except:
            host = 'localhost'
    try:
        port = int(sys.argv[2])
    except IndexError, ValueError:
        port = 8000
    httpd = make_server(host, port, application)
    print """You will be able to access the application at:
http://{0}:{1}""".format(host, port)
    httpd.serve_forever()


session = Session()
session.environment = "apache"
serv = SimpleServer(session, os.path.join(cheshire3Root,
                                          'configs',
                                          'serverConfig.xml'))
application = EADSearchWsgiApplication()


if __name__ == "__main__":
    sys.exit(main())