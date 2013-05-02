#!/bin/env python
u"""Manage Archives Hub Contributors."""

import os
import sys

from lxml import etree
from lxml.builder import ElementMaker

from cheshire3.baseObjects import Session
from cheshire3.exceptions import ObjectDoesNotExistException
from cheshire3.internal import CONFIG_NS
from cheshire3.record import LxmlRecord
from cheshire3.server import SimpleServer

from cheshire3.commands.cmd_utils import identify_database

from archiveshub.commands.utils import BaseArgumentParser


class ContribArgumentParser(BaseArgumentParser):
    """Custom option parser for Archives Hub contributor management."""
    
    def __init__(self, *args, **kwargs):
        super(ContribArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")


def add_contributor(args):
    """Add named contributor(s).
    
    Add DocumentStore configuration(s) for named contributor(s) to the
    ConfigStore for this database. 
    """
    global session, db, lgr
    # Get ConfigStore in which to store DocumentStore
    store = db.get_object(session, 'documentStoreConfigStore')
    for name in args.name:
        # Generate identifier for new DocumentStore
        identifier = "{0}DocumentStore".format(name)
        # Check that DocumentStore does not already exists
        try:
            store.fetch_object(session, identifier)
        except ObjectDoesNotExistException:
            # This is what we want!
            pass
        else:
            lgr.log_error(session, "DocumentStore for {0} has already been "
                                   "registered".format(name))
            continue
        # Process args
        if args.dir:
            # Simple Directory
            objType = "cheshire3.documentStore.DirectoryDocumentStore"
            dbPath = args.dir
        else:
            # Mercurial repository directory
            objType = "archiveshub.documentStore.MercurialDocumentStore"
            dbPath = os.path.join(args.mercurial, name)
        # Create config node for the new DocumentStore
        config = CONF.config(
            {'id': identifier,
             'type': 'documentStore'},
            CONF.docs("DocumentStore for contributor {0}".format(name)),
            CONF.objectType(objType),
            # <paths>
            CONF.paths(
                CONF.path(
                    {'type': "databasePath"},
                    dbPath
                ),
                CONF.object(
                    {'type': "idNormalizer", 'ref': "IdToFilenameNormalizer"}
                ),
                CONF.object(
                    {'type': "outIdNormalizer", 'ref': "FilenameToIdNormalizer"}
                ),
            ),
        )
        xml = etree.tostring(config)
        # Store the configuration
        rec = LxmlRecord(config, xml, byteCount=len(xml))
        rec.id = identifier
        store.begin_storing(session)
        store.store_record(session, rec)
        store.commit_storing(session)
        lgr.log_info(session, "DocumentStore for {0} located at {1} has been "
                              "added".format(identifier, dbPath)
        )
        # TODO: write new contributor into JSON


def main(argv=None):
    global argparser
    global session, server, db, lgr
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    # Initialize Cheshire3 environment
    session = Session()
    server = SimpleServer(session, args.serverconfig)
    # Get the Database 
    if args.database is None:
        try:
            dbid = identify_database(session, os.getcwd())
        except EnvironmentError as e:
            server.log_critical(session, e.message)
            return 1
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
        return 2
    else:
        # Fetch a Logger
        lgr = db.get_path(session, 'defaultLogger')

    # Call 
    return args.func(args)


# Init ArgumentParser
docbits = __doc__.split('\n\n')
argparser = ContribArgumentParser(conflict_handler='resolve',
                               description=docbits[0]
                               )
subparsers = argparser.add_subparsers(help='Actions')
parser_add = subparsers.add_parser('add', help='Add a new contributor')
parser_add.add_argument('name',
                        nargs='+',
                        action='store',
                        help=("short identifier for contributor.")
                        )
group = parser_add.add_mutually_exclusive_group()
group.add_argument('-m', '--hg',
                   action='store', dest='mercurial',
                   default=os.path.expanduser("~/mercurial/hubdata"),
                   help=("mercurial repository in which to find documents "
                         "for this contributor. defaults to "
                         "~/mercurial/hubdata"
                         )
                   )
group.add_argument('--dir',
                   action='store', dest='dir',
                   default=None,
                   help=("simple directory in which to find documents for "
                         "this contributor. NOTE: using this option will "
                         "result in directory NOT being treated as part of a "
                         "mercurial repository")
                   )

parser_add.set_defaults(func=add_contributor)


# Set up ElementMaker for Cheshire3 config and METS namespaces
CONF = ElementMaker(namespace=CONFIG_NS,
                    nsmap={'cfg': CONFIG_NS})


if __name__ == '__main__':
    sys.exit(main())
