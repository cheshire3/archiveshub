"""Start an HTTP server for Cheshire3 for Archives

Start an HTTP server to expose Cheshire3 databases via the web services and 
web application for development and demonstration purposes.

The current implementation uses CherryPy. 
"""
import sys
import socket
import signal

from cherrypy.wsgiserver import CherryPyWSGIServer, WSGIPathInfoDispatcher

from cheshire3.server import SimpleServer
from cheshire3.session import Session
from cheshire3.web.sruWsgi import SRUWsgiHandler, get_configsFromServer
from cheshire3.web.oaipmhWsgi import OAIPMHWsgiApplication
from cheshire3.web.oaipmhWsgi import get_databasesAndConfigs

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
    c3_session = Session()
    c3_server = SimpleServer(c3_session, args.serverconfig)
    # Init SRU App
    sru_configs = get_configsFromServer(c3_session, c3_server)
    sru_app = SRUWsgiHandler(c3_session, sru_configs)
    # Init OAI-PMH App
    dbs, oaipmh_configs = get_databasesAndConfigs(c3_session, c3_server)
    oaipmh_app = OAIPMHWsgiApplication(c3_session, oaipmh_configs, dbs)
    dispatcher = WSGIPathInfoDispatcher([
        ('/api/sru', sru_app),
        ('/api/oaipmh/2.0', oaipmh_app),
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
    sys.stdout.write("Starting CherryPy HTTP server for Cheshire3 for Archives"
                     ".\n")
    sys.stdout.write("If running in foreground Ctrl-C will stop the server.\n")
    sys.stdout.write("You will be able to access the applications from:\n")
    sys.stdout.write("http://{0}:{1}\n""".format(args.hostname, args.port))
    sys.stdout.flush()
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
