#!/bin/env python
u"""Clear the Cheshire3 for Archives database(s)."""

import sys
import os
import time

from lockfile import FileLock

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer

from cheshire3.commands.cmd_utils import identify_database

from cheshire3archives.commands.utils import BaseArgumentParser


class ClearArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""
    
    def __init__(self, *args, **kwargs):
        super(ClearArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        self.add_argument("-a", "--all", 
                          action="store_true", dest="all",
                          default=False, 
                          help=("clear entire Cheshire3 for Archives"
                                "system (i.e. same as --main --clusters.)"
                                " Excludes all other operations.")
                          )
        self.add_argument("-m", "--main",
                          action="store_true", dest="main",
                          default=False,
                          help="clear database of EAD documents and components"
                          )
        self.add_argument("-s", "--subjects", 
                          action="store_true", dest="clusters",
                          default=False, 
                          help="clear subject clusters"
                          )


def clear(args):
    global session, db, lgr
    lgr.log_info(session,
                 "Clearing database of EAD documents and components..."
                 )
    start = time.time()
    db.begin_indexing(session)
    if not db.indexes:
        db._cacheIndexes(session)
    for idx in db.indexes.itervalues():
        if not idx.get_setting(session, 'noUnindexDefault', 0):
            idx.clear(session)
    db.commit_indexing(session)
    db.commit_metadata(session)
    # Clear recordStore
    recordStore = db.get_object(session, 'recordStore')
    recordStore.clear(session)
    # Clear componentStore
    componentStore = db.get_object(session, 'componentStore')
    componentStore.clear(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
                 )
    return 0


def clear_clusters(args):
    global session, db, lgr
    lgr.log_info(session, 'Clearing subject clusters...')
    start = time.time()
    session.database = '{0}_cluster'.format(session.database)
    clusDb = server.get_object(session, session.database)
    clusDb.clear_indexes(session)
    # Clear clusterStore
    clusterStore = clusDb.get_object(session, 'eadClusterStore')
    clusterStore.clear(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
                 )
    # return session.database to the default (finding aid) DB
    session.database = db.id
    return 0


def _conditional_clear(args):
    # Check arguments and call necessary load methods
    if args.all:
        # if exclusive --all option
        # sum return values - should all return 0
        retval = sum([clear(args),
                      clear_clusters(args)
                     ])
        return retval
    
    # Check individual load args
    retval = 0
    if args.main:
        retval += clear(args)
    # Subject clusters    
    if args.clusters:
        retval += clear_clusters(args)
        
    return retval


def main(argv=None):
    global argparser, lockfilepath, lgr
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
    try:
        _conditional_clear(args)
    finally:
        lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = ClearArgumentParser(conflict_handler='resolve',
                               description=docbits[0]
                               )

if __name__ == '__main__':
    sys.exit(main())
