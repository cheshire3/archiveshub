"""Start a demo server for Cheshire3 for Archives

Start an HTTP server to expose Cheshire3 databases via the web services and 
web application development and demonstration purposes.

For production use it may be advisable to deploy the server via a production
ready WSGI server or framework (e.g. CherryPy, mod_wsgi etc.) 
"""
import sys
import socket
import signal

from cherrypy.wsgiserver import CherryPyWSGIServer, WSGIPathInfoDispatcher

from cheshire3.server import SimpleServer
from cheshire3.session import Session
from cheshire3.web.sruWsgi import application as sru_app

from cheshire3archives.commands.utils import WSGIAppArgumentParser

from cheshire3archives.apps.ead.search import application as ead_search_app
from cheshire3archives.apps.ead.record import application as ead_data_app


def main(argv=None):
    """Start up a CherryPy server to serve the SRU application."""
    global argparser, c3_session, c3_server
    global sru_app, ead_search_app, ead_data_app  # WSGI Apps
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    session = Session()
    server = SimpleServer(session, args.serverconfig)
    dispatcher = WSGIPathInfoDispatcher([
        ('/api/sru', sru_app),
        ('/ead/data', ead_data_app),
        ('/ead', ead_search_app)
    ])
    wsgi_server = CherryPyWSGIServer((args.hostname, args.port),
                                     dispatcher,
                                     server_name="Cheshire3 for Archives")
    def signal_handler(signal, frame):
        wsgi_server.stop()
        sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)
    wsgi_server.start()
    
    
c3_session = None
c3_server = None

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == '__main__':
    main()
