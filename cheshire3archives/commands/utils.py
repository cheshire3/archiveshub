"""Command line utils for Cheshire3 for Archives Command-line UI."""

import socket

from cheshire3.commands.cmd_utils import Cheshire3ArgumentParser


class BaseArgumentParser(Cheshire3ArgumentParser):
    
    def __init__(self, *args, **kwargs):
        Cheshire3ArgumentParser.__init__(self, *args, **kwargs)


class WSGIAppArgumentParser(BaseArgumentParser):

    def __init__(self, *args, **kwargs):
        BaseArgumentParser.__init__(self, *args, **kwargs)
        # Find default hostname
        try:
            hostname = socket.gethostname()
        except:
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