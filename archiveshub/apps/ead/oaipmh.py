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
from cheshire3.exceptions import (
    C3Exception,
    ObjectDeletedException,
    ObjectDoesNotExistException,
    FileDoesNotExistException
)
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

    def _listResults(self, metadataPrefix, set_=None, from_=None, until=None):
        """Return a list of (datestamp, resultSet) tuples.

        Suitable for use by:
            - listIdentifiers
            - listRecords
        """
        session = self.session
        # Check set value
        if set_ and not set_.startswith('contributor:'):
            raise StopIteration
        elif set_:
            set_ = set_.split(':', 1)[-1]

        if until and until < self.earliestDatestamp:
            raise BadArgumentError('until argument value is earlier than '
                                   'earliestDatestamp.')
        if not from_:
            from_ = self.earliestDatestamp
        if not until:
            until = datetime.datetime.now()
            #(from_ < self.earliestDatestamp)
        if (until < from_):
            raise BadArgumentError('until argument value is earlier than from '
                                   'argument value.')
        q = cqlparse('rec.lastModificationDate > "%s" and '
                     'rec.lastModificationDate < "%s"' % (from_, until)
                     )
        # Actually need datestamp values as well as results - interact with
        # indexes directly for efficiency
        # Get CQL ProtocolMap
        pm = self.db.get_path(session, 'protocolMap')
        idx = pm.resolveIndex(session, q.leftOperand)
        q.config = pm
        res = {}
        for src in idx.sources[u'data']:
            res.update(src[1].process(session, [[str(from_)]]))
            res.update(src[1].process(session, [[str(until)]]))
        from_ = min(res.keys())
        until = max(res.keys())
        # Tweak until value to make it inclusive
        until = until[:-1] + chr(ord(until[-1]) + 1)
        termList = idx.fetch_termList(session, from_, 0, '>=', end=until)
        # Generate sequence of datestamp, resultSet tuples
        for t in termList:
            try:
                datetime_obj = datetime.datetime.strptime(
                    t[0],
                    u'%Y-%m-%dT%H:%M:%S'
                )
            except ValueError:
                datetime_obj = datetime.datetime.strptime(
                    t[0],
                    u'%Y-%m-%d %H:%M:%S'
                )
            datetime_rs = idx.construct_resultSet(session, t[1])
            if not set_:
                yield (datetime_obj, datetime_rs)
            else:
                # Filter by set
                set_q = cqlparse('vdb.identifier = {0}'.format(set_))
                set_rs = self.db.search(session, set_q)
                full_rs = SimpleResultSet(session)
                full_q = cqlparse('{0} and {1}'
                                  ''.format(q.toCQL(), set_q.toCQL()))
                yield (datetime_obj, full_rs.combine(session,
                                                     [datetime_rs, set_rs],
                                                     full_q
                                                     )
                       )

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
        if (
            metadataPrefix and not
            (metadataPrefix in self.protocolMap.recordNamespaces)
        ):
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
                try:
                    r.fetch_record(session)
                except (
                    ObjectDeletedException,
                    ObjectDoesNotExistException,
                    FileDoesNotExistException
                ) as e:
                    headers.append(Header(identifier, datestamp, sets, True))
                else:
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
                try:
                    rec = r.fetch_record(session)
                except (
                    ObjectDeletedException,
                    ObjectDoesNotExistException,
                    FileDoesNotExistException
                ) as e:
                    records.append((Header(identifier, datestamp, sets, True),
                                    None,
                                    None
                                    ))
                else:
                    records.append((Header(identifier, datestamp, sets, None),
                                    rec,
                                    None
                                    ))
                i += 1
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
