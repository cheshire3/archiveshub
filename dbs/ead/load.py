#!/bin/env python
#
# Script:    load.py
# Date:      7 May 2013
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Load the Archives Hub database of EAD finding aid documents.

usage: load.py [-h] [-s PATH] [-d DATABASE] [-c] [ID [ID ...]]

optional arguments:
  -h, --help            show this help message and exit
  -c, --components      load components from loaded EAD records
"""

import os
import sys
import time

from lockfile import FileLock

from cheshire3.baseObjects import Session
from cheshire3.exceptions import ObjectDoesNotExistException
from cheshire3.server import SimpleServer

from cheshire3.commands.cmd_utils import identify_database

from archiveshub.commands.utils import BaseArgumentParser


class LoadArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        super(LoadArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        self.add_argument("-c", "--components",
                          action="store_true", dest="components",
                          default=False,
                          help=("load and index components from loaded EAD "
                                "records")
                          )
        self.add_argument('identifier',
                          nargs='*',
                          action='store',
                          metavar="ID",
                          help=("identifier for contributor(s) to load")
                          )


def load(args):
    """Load named contributor(s).

    Load the Documents for the named contributor(s) into the internal
    RecordStore.
    """
    global session, db, lgr
    lgr.log_info(session, 'Loading and indexing...')
    start = time.time()
    # Get ConfigStore where the DocumentStores are stored
    store = db.get_object(session, 'documentStoreConfigStore')
    if args.identifier:
        storeIterator = []
        for contributorId in args.identifier:
            # Sanity checking
            if os.path.exists(contributorId) and os.path.isdir(contributorId):
                # They've given the directory - try to derive identifier
                contributorId.rstrip(os.pathsep)
                contributorId = os.path.basename(contributorId)
            # Generate identifier for new DocumentStore
            storeId = "{0}DocumentStore".format(contributorId)
            try:
                storeIterator.append(store.fetch_object(session, storeId))
            except ObjectDoesNotExistException:
                # Contributor with this id does not exist
                lgr.log_error(session,
                              "Contributor with identifier {0} does not seem to "
                              "exist. It's possible that the default identifier "
                              "for the directory was over-ridden with the --id "
                              "option - you'll need to specify the identifier "
                              "instead of the directory name".format(contributorId)
                              )
    else:
        storeIterator = store
    
    # Now iterate over the selected stores
    for contributorStore in storeIterator:
        contributorId = contributorStore.id[:-len('DocumentStore')]
        wf = db.get_object(session, 'loadWorkflow')
        wf.process(session, contributorStore)
        lgr.log_info(session,
                     "Documents for {0} have been loaded"
                     "".format(contributorId)
        )
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session,
                 ('Loading, Indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
                  ''.format(hours, mins, secs))
                 )
    return 0


def main(argv=None):
    global argparser
    global session, server, db, lgr
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)

    session = Session()
    server = SimpleServer(session, args.serverconfig)
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
        lgr = db.get_path(session, 'defaultLogger')
        pass

    mp = db.get_path(session, 'metadataPath')
    lock = FileLock(mp)
    try:
        lock.acquire(timeout=30)    # wait up to 30 seconds
    except LockTimeout:
        msg = ("The database is locked. It is possible that another"
               "user is currently indexing this database. Please wait at least" 
               "10 minutes and then try again. If you continue to get this "
               "message and you are sure no one is reindexing the database "
               "please contact the archives hub team for advice."
               )
        lgr.log_critical(session, msg)
        return 1
    # Call
    try:
        return load(args)
    finally:
        lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = LoadArgumentParser(conflict_handler='resolve',
                              description=docbits[0]
                              )


if __name__ == '__main__':
    sys.exit(main())
