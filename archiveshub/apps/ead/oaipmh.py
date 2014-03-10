"""Archives Hub OAI-PMH Implementation.
"""
from __future__ import absolute_import

import datetime
import os
import sys

from cgi import FieldStorage
from itertools import islice
from xml.sax.saxutils import escape

from oaipmh.common import Header
from oaipmh.error import (
    DatestampError,
    BadArgumentError,
    CannotDisseminateFormatError
    )

# Import Some necessary Cheshire3 bits
from cheshire3.baseObjects import Session
from cheshire3.cqlParser import parse as cqlparse
from cheshire3.exceptions import C3Exception
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.resultSet import SimpleResultSet
from cheshire3.web.oaipmhHandler import (
    Cheshire3OaiServer,
    MinimalOaiServer,
    Cheshire3OaiMetadataWriter,
    get_databasesAndConfigs
    )
from cheshire3.web.oaipmhWsgi import OAIPMHWsgiApplication

from .base import iterContributors


class ArchivesHubOAIServer(Cheshire3OaiServer):
    """Customized OAI-PMH Server for the Archives Hub.

    This customized sub-class of Cheshire3OaiServer allows the implementation
    of a simple set hierarchy for the contributors.
    """

    def listIdentifiers(self, metadataPrefix, set=None, from_=None, until=None,
                        cursor=0, batch_size=10):
        """Return a list of Header objects for matching records.

        Return a list of Header objects for records which match the given
        parameters.

        metadataPrefix
            identifies metadata set to retrieve

        set
            set identifier; only return headers in set (optional)

        from_
            only retrieve headers from from_ date forward (optional)

        until
            only retrieve headers with dates up to and including until date
            (optional)

        Should raise error.CannotDisseminateFormatError if metadataPrefix is
        not supported by the repository.

        Should raise error.NoSetHierarchyError if the repository does not
        support sets.
        """
        if (metadataPrefix and not
            (metadataPrefix in self.protocolMap.recordNamespaces)):
            raise CannotDisseminateFormatError()
        # Get list of datestamp, resultSet tuples
        tuples = self._listResults(metadataPrefix, set, from_, until)
        # Need to return iterable of header objects
        # Header(identifier, datestamp, setspec, deleted)
        # identifier: string, datestamp:
        # datetime.datetime instance
        # setspec: list
        # deleted: boolean?
        headers = []
        i = 0
        set_idx = self.db.get_object(session, 'idx-vdbid')
        for (datestamp, rs) in tuples:
            for r in rs:
                if i < cursor:
                    i += 1
                    continue
                # Handle non-ascii characters in identifier
                identifier = unicode(r.id, 'utf-8')
                identifier = identifier.encode('ascii', 'xmlcharrefreplace')
                # Sets
                sets = []
                vec = set_idx.fetch_vector(session, r)
                for t in vec[2]:
                    vdbid = set_idx.fetch_termById(session, t[0])
                    sets.append('contributor:{0}'.format(vdbid))
                headers.append(Header(identifier, datestamp, sets, None))
                i += 1
                if (len(headers) >= batch_size):
                    return headers
        return headers

    def listRecords(self, metadataPrefix, set=None, from_=None, until=None,
                    cursor=0, batch_size=10):
        """Return a list of records.

        Return a list of (header, metadata, about) tuples for records which
        match the given parameters.

        metadataPrefix
            identifies metadata set to retrieve

        set
            set identifier; only return records in set (optional)

        from_
            only retrieve records from from_ date forward (optional)

        until
            only retrieve records with dates up to and including until date
            (optional)

        Should raise error.CannotDisseminateFormatError if metadataPrefix is
        not supported by the repository.

        Should raise error.NoSetHierarchyError if the repository does not
        support sets.
        """
        session = self.session
        if (
            metadataPrefix and not
            (metadataPrefix in self.protocolMap.recordNamespaces)
        ):
            raise CannotDisseminateFormatError()

        if not self.metadataRegistry.hasWriter(metadataPrefix):
            # Need to create a 'MetadataWriter' for this schema for oaipmh to
            # use, and put in self.metadataRegister
            schemaId = self.protocolMap.recordNamespaces[metadataPrefix]
            txr = self.protocolMap.transformerHash.get(schemaId, None)
            mdw = Cheshire3OaiMetadataWriter(txr)
            self.metadataRegistry.registerWriter(metadataPrefix, mdw)
        # Get list of datestamp, resultSet tuples
        tuples = self._listResults(metadataPrefix, set, from_, until)
        # Need to return iterable of (header, metadata, about) tuples
        # Header(identifier, datestamp, setspec, deleted)
        # identifier: string, datestamp: datetime.datetime instance
        # setspec: list
        # deleted: boolean?
        set_idx = self.db.get_object(session, 'idx-vdbid')
        records = []
        i = 0
        for (datestamp, rs) in tuples:
            for r in rs:
                if i < cursor:
                    i+=1
                    continue
                rec = r.fetch_record(session)
                # Handle non-ascii characters in identifier
                identifier = unicode(r.id, 'utf-8')
                identifier = identifier.encode('ascii', 'xmlcharrefreplace')
                # Sets
                sets = []
                vec = set_idx.fetch_vector(session, r)
                for t in vec[2]:
                    vdbid = set_idx.fetch_termById(session, t[0])
                    sets.append('contributor:{0}'.format(vdbid))
                records.append((Header(identifier, datestamp, sets, None),
                                rec,
                                None))
                i+=1
                if (len(records) == batch_size):
                    return records
        return records

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
