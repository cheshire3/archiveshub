"""Archives Hub OAI-PMH Implementation.
"""
from __future__ import absolute_import

import datetime
import os
import sys

from cgi import FieldStorage
from itertools import islice
from xml.sax.saxutils import escape

from oaipmh.error import (
    DatestampError,
    BadArgumentError
    )

# Import Some necessary Cheshire3 bits
from cheshire3.baseObjects import Session
from cheshire3.exceptions import C3Exception
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.web.oaipmhHandler import (
    Cheshire3OaiServer,
    MinimalOaiServer,
    get_databasesAndConfigs
    )
from cheshire3.web.oaipmhWsgi import OAIPMHWsgiApplication

from .base import iterContributors


class ArchivesHubOAIServer(Cheshire3OaiServer):
    """Customized OAI-PMH Server for the Archives Hub.
    
    This customized sub-class of Cheshire3OaiServer allows the implementation
    of a simple set hierarchy for the contributors.
    """

    def listSets(self, cursor=0, batch_size=10):
        """Return an iterable of sets.

        Return an iterable of (setSpec, setName) tuples (tuple items are
        strings).

        Should raise error.NoSetHierarchyError if the repository does not
        support sets.
        """
        global session
        sets = []
        iterator = iterContributors(session)
        for vdbid, set_name in islice(iterator, cursor, cursor + batch_size):
            set_spec = "contributor:{0}".format(vdbid)
            set_desc = "This set contains metadata from {0}".format(set_name)
            sets.append((set_spec, set_name, set_desc))
        return sets


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
    except (IndexError, ValueError):
        port = 8000
    httpd = make_server(host, port, application)
    print """You will be able to access the application at:
http://{0}:{1}""".format(host, port)
    httpd.serve_forever()


# Cheshire3 architecture
session = Session()
serv = SimpleServer(session,
                    os.path.join(cheshire3Root, 'configs', 'serverConfig.xml')
                    )
lxmlParser = serv.get_object(session, 'LxmlParser')
dbs, configs = get_databasesAndConfigs(session, serv)
c3OaiServers = {}

application = OAIPMHWsgiApplication(
    session,
    configs,
    dbs,
    serverClass=ArchivesHubOAIServer
)


if __name__ == "__main__":
    sys.exit(main())
