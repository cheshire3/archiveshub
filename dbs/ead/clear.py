#!/bin/env python
u"""Clear the Cheshire3 for Archives database(s)."""

import sys
import os
import time

from lockfile import FileLock, LockTimeout

from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.commands.utils import BaseArgumentParser, getCheshire3Env


class ClearArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""
    
    def __init__(self, *args, **kwargs):
        super(ClearArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
#        self.add_argument("-a", "--all", 
#                          action="store_true", dest="all",
#                          default=False, 
#                          help=("clear entire Cheshire3 for Archives"
#                                "system (i.e. same as --main --clusters.)"
#                                " Excludes all other operations.")
#                          )
#        self.add_argument("-m", "--main",
#                          action="store_true", dest="main",
#                          default=False,
#                          help="clear database of EAD documents and components"
#                          )


def clear_stores(args):
    "Clear internal data stores."
    global session, db
    lgr = session.logger
    lgr.log_info(
        session,
        "Clearing database of EAD documents and components..."
    )
    start = time.time()
    # Clear recordStore
    recordStore = db.get_object(session, 'recordStore')
    recordStore.clear(session)
    # Clear componentStore
    componentStore = db.get_object(session, 'componentStore')
    componentStore.clear(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Finished ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
                 )
    return 0


def clear_indexes(args):
    "Clear indexes."
    global session, db
    lgr = session.logger
    lgr.log_info(session, 'Clearing indexes...')
    start = time.time()
    db.begin_indexing(session)
    if not db.indexes:
        db._cacheIndexes(session)
    for idx in db.indexes.itervalues():
        if not idx.get_setting(session, 'noUnindexDefault', 0):
            idx.clear(session)
    db.commit_indexing(session)
    # Clear database metadata
    db.totalItems = 0
    db.totalWordCount = db.minWordCount = db.maxWordCount = 0
    db.totalByteCount = db.minByteCount = db.maxByteCount = 0
    db.commit_metadata(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(
        session, 
        'Finished ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, mins, secs)
    )
    # Clear resultSetStore - no longer valid if indexes change
    return clear_resultSets(args)


def clear_clusters(args):
    "Clear subject finder."
    global session, db
    lgr = session.logger
    lgr.log_info(session, 'Clearing subject finder...')
    start = time.time()
    session.database = '{0}_cluster'.format(session.database)
    clusDb = server.get_object(session, session.database)
    clusDb.clear_indexes(session)
    # Clear clusterStore
    clusterStore = clusDb.get_object(session, 'eadClusterStore')
    clusterStore.clear(session)
    # Clear database metadata
    clusDb.totalItems = 0
    clusDb.totalWordCount = clusDb.minWordCount = clusDb.maxWordCount = 0
    clusDb.totalByteCount = clusDb.minByteCount = clusDb.maxByteCount = 0
    clusDb.commit_metadata(session)
    # Report time taken
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Finished ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
                 )
    # return session.database to the default (finding aid) DB
    session.database = db.id
    return 0


def clear_resultSets(args):
    "Clear stored ResultSets."
    global session, db
    lgr = session.logger
    lgr.log_info(session,
                 "Clearing stored resultSets..."
                 )
    start = time.time()
    resultSetStore = db.get_object(session, 'eadResultSetStore')
    resultSetStore.clear(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Finished ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
                 )
    return 0


def main(argv=None):
    global argparser, lockfilepath
    global session, server, db
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    try:
        session, server, db = getCheshire3Env(args)
    except (EnvironmentError, ObjectDoesNotExistException):
        return 1
    with db.get_path(session, 'defaultLogger') as session.logger:
        mp = db.get_path(session, 'metadataPath')
        lock = FileLock(mp)
        if lock.is_locked() and args.unlock:
            # Forcibly unlock
            session.logger.log_warning(session, "Unlocking Database")
            lock.break_lock()
        try:
            lock.acquire(timeout=30)    # wait up to 30 seconds
        except LockTimeout:
            msg = ("The database is locked. It is possible that another"
                   "user is currently indexing this database. Please wait at "
                   "least 10 minutes and then try again. If you continue to "
                   "get this message and you are sure no one is reindexing "
                   "the database please contact the archives hub team for "
                   "advice."
                   )
            session.logger.log_critical(session, msg)
            return 1
        try:
            return args.func(args)
        finally:
            lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = ClearArgumentParser(conflict_handler='resolve',
                               description=docbits[0]
                               )
argparser.add_argument('-u', '--unlock', action='store_true',
                       dest='unlock',
                       help=("if the database is currently locked, force "
                             "unlock it before proceeding to requested "
                             "operation"
                            )
                       )
# Subparsers for commands
subparsers = argparser.add_subparsers(title='Commands')
# clear.py main
parser_main = subparsers.add_parser(
    "stores",
    help="clear internal stores of EAD documents and components"
)
parser_main.set_defaults(func=clear_stores)
# clear.py index
parser_index = subparsers.add_parser(
    "indexes",
    help="clear indexes"
)
parser_index.set_defaults(func=clear_indexes)
# clear.py subject
parser_subject = subparsers.add_parser(
    "subjects", 
    help="clear subject finder"
)
parser_subject.set_defaults(func=clear_clusters)
# clear.py results
parser_rss = subparsers.add_parser(
    "results", 
    help="clear stored ResultSets"
)
parser_rss.set_defaults(func=clear_resultSets)


if __name__ == '__main__':
    sys.exit(main())
