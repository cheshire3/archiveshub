"""Command line utils for Cheshire3 for Archives Command-line UI."""

import os
import socket

from cheshire3.baseObjects import Session
from cheshire3.exceptions import ObjectDoesNotExistException
from cheshire3.server import SimpleServer

from cheshire3.commands.cmd_utils import identify_database
from cheshire3.commands.cmd_utils import Cheshire3ArgumentParser


class BaseArgumentParser(Cheshire3ArgumentParser):
    
    def __init__(self, *args, **kwargs):
        Cheshire3ArgumentParser.__init__(self, *args, **kwargs)


class WSGIAppArgumentParser(BaseArgumentParser):

    def __init__(self, *args, **kwargs):
        BaseArgumentParser.__init__(self, *args, **kwargs)
        # Set default hostname
        hostname = '127.0.0.1'
        self.add_argument('--hostname', type=str,
                          action='store', dest='hostname',
                          default=hostname, metavar='HOSTNAME',
                          help=("name of host to listen on. default "
                                "derived by inspection of local system"
                                )
                          )
        self.add_argument('-p', '--port', type=int,
                          action='store', dest='port',
                          default=8000, metavar='PORT',
                          help="number of port to listen on. default: 8000"
                          )
        self.add_argument('--no-browser',
                          action='store_false', dest='browser',
                          default=True,
                          help=("don't open a browser window/tab containing the "
                                "app. useful if you want to deploy the app for "
                                "other users"
                                )
                          )


def getCheshire3Env(args):
    """Init and return Cheshire3 Session, Server and Database.
    
    Intialize Cheshire3 Session, Server and Database objects based on
    ``args``.
    """
    # Create a Session
    session = Session()
    # Get the Server based on given serverConfig file
    server = SimpleServer(session, args.serverconfig)
    # Try to get the Database
    if args.database is None:
        try:
            dbid = identify_database(session, os.getcwd())
        except EnvironmentError as e:
            server.log_critical(session, e.message)
            raise
        server.log_debug(
            session, 
            "database identifier not specified, discovered: {0}".format(dbid))
    else:
        dbid = args.database
    try:
        db = server.get_object(session, dbid)
    except ObjectDoesNotExistException:
        msg = """Cheshire3 database {0} does not exist.
Please provide a different database identifier using the --database option.
""".format(dbid)
        server.log_critical(session, msg)
        raise
    else:
        # Attach a default Logger to the Session
        session.logger = db.get_path(session, 'defaultLogger')
    
    return session, server, db
