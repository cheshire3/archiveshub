"""Start a demo server for Cheshire3 for Archives

Start an HTTP server to expose Cheshire3 databases via the web services and 
web application development and demonstration purposes.

For production use it may be advisable to deploy the server via a production
ready WSGI server or framework (e.g. CherryPy, mod_wsgi etc.) 
"""

import socket

#from wsgiref.simple_server import make_server
import tornado.web
import tornado.httpserver
import tornado.wsgi

from cheshire3.server import SimpleServer
from cheshire3.session import Session
from cheshire3.web.sruWsgi import SRUWsgiHandler

from cheshire3archives.commands.utils import WSGIAppArgumentParser

from cheshire3archives.apps.ead.search import application as ead_search_app
from cheshire3archives.apps.ead.record import application as ead_data_app


def main(argv=None):
    """Start up a simple app server to serve the SRU application."""
    global argparser, session, server
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    session = Session()
    server = SimpleServer(session, args.serverconfig)
    sru_app = SRUWsgiHandler()
    container = tornado.web.Application(
        [
            (r"/services",
             tornado.web.RedirectHandler,
             dict(url="/api/sru")
             ),
            (r'/api/sru/.*',
             tornado.web.FallbackHandler,
             dict(fallback=tornado.wsgi.WSGIContainer(sru_app))
             ),
            (r'/ead/data/.*',
             tornado.web.FallbackHandler,
             dict(fallback=tornado.wsgi.WSGIContainer(ead_data_app))
             ),
            (r'/ead/.*',
             tornado.web.FallbackHandler,
             dict(fallback=tornado.wsgi.WSGIContainer(ead_search_app))
             ),
         ])
    http_server = tornado.httpserver.HTTPServer(container)
    http_server.listen(args.port)
    print """You will be able to access the application at:
    http://{0}:{1}""".format(args.hostname, args.port)
    tornado.ioloop.IOLoop.instance().start()


session = None
server = None

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == '__main__':
    main()
