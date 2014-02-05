#!/bin/env python
# -*- coding: utf-8 -*-
# Script:    index.py
# Date:      21 November 2013
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Index the Archives Hub database of EAD finding aid documents.

usage: index.py [-h] [-s PATH] [-d DATABASE] [-j] [-n] [-b | -l | -o]

optional arguments:
  -h, --help            show this help message and exit
  -s PATH, --server-config PATH
                        path to Cheshire3 server configuration file. default:
                        /home/cheshire/cheshire3/cheshire3/configs/serverConfi
                        g.xml
  -d DATABASE, --database DATABASE
                        identifier of Cheshire3 database
  -j, --subjects        load and index subject finder
  -u, --unlock          if the database is currently locked, force unlock it
                        before proceeding to requested operation.

Commands:
  {background,live}
    background          load into offline indexes, replace live indexes when
                        complete
    live                load directly into the live indexes. not recommended
                        for production use



"""

import math
import os
import shutil
import sys
import time

from lockfile import FileLock, LockTimeout

from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.deploy.utils import BaseArgumentParser, getCheshire3Env

# Define some test queries. Each item in the list should be a pair of:
# (CQLQuery, threshold) where threshold is the mininum number of results the
# query must return before accepting new Indexes  
TEST_QUERIES = [
   ('cql.anywhere all "papers"', 50000),
   ('cql.anywhere all "police"', 1000),
   ('bath.name all "greene"', 10)
]


class IndexArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        super(IndexArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          help="identifier of Cheshire3 database")
        self.add_argument("-j", "--subjects",
                          action="store_true", dest="clusters",
                          help="load and index subject finder"
                          )
        self.add_argument('-u', '--unlock', action='store_true',
                          dest='unlock',
                          help=("if the database is currently locked, force "
                                "unlock it before proceeding to requested "
                                "operation."
                                )
                          )
        self.add_argument("--descriptions-only", "--no-components",
                          action='store_false',
                          dest='components',
                          help=("load only collection-level descriptions")
                          )
        self.add_argument("--no-descriptions", "--components-only",
                          action='store_false',
                          dest='main',
                          help=("load only components")
                          )


def _index_recordStore(recordStore):
    # Index all Records in a RecordStore
    global session, db
    lgr = session.logger
    for ctr, rec in enumerate(recordStore):
        try:
            db.index_record(session, rec)
        except UnicodeDecodeError:
            lgr.log_error(
                session, 
                'REC: {0:>10} {1.id:<40} [ERROR] - Some indexes not built; '
                'non unicode characters'.format(ctr, rec)
            )
        else:
            # Assimilate metadata of Record
            db.add_record(session, rec)
            # Do not log every record - causes terminal to bog down
            # Log only at the current order of magnitude
            if ctr > 0 and not(ctr % 10 ** int(math.log10(ctr))):
                lgr.log_info(
                    session,
                    'REC: {0:>10} {1.id:<40} [OK]'.format(ctr, rec)
                )


def _index(session, db, args):
    # Index Records
    db.begin_indexing(session)
    if args.main:
        _index_recordStore(db.get_object(session, 'recordStore'))
    if args.components:
        _index_recordStore(db.get_object(session, 'componentStore'))

    session.logger.log_info(session, 'Merging index terms')

    for idx in db.indexes.itervalues():
        if not idx.get_setting(session, 'noIndexDefault', 0):
            session.logger.log_info(session,
                                    'Merging index terms for {0}'
                                    ''.format(idx.id)
                                    )
            idx.commit_indexing(session)

    db.commit_metadata(session)


def test_expectedResults(args):
    """Check that searches return the expected results.

    Check that pre-defined searches return at least a pre-defined number of
    hits.
    """
    global session, db
    lgr = session.logger
    qf = db.get_object(session, 'defaultQueryFactory')
    for qString, threshold in TEST_QUERIES:
        q = qf.get_query(session, qString)
        rs = db.search(session, q)
        if len(rs) < threshold:
            lgr.log_error(session,
                          'Failed test for {0}; {1} hits < {2}'
                          ''.format(qString, len(rs), threshold)
                          )
            return False
        else:
            lgr.log_debug(session,
                         'Passed test for {0}; {1} hits >= {2}'
                         ''.format(qString, len(rs), threshold)
                         )
    # After loop completes, i.e. all tests pass
    return True


def commit_backgroundIndexing(args):
    """Commit new indexes in place of old."""
    global session, db
    lgr = session.logger
    lgr.log_debug(session, 'Replacing existing live indexes')
    indexStore = db.get_object(session, 'indexStore')
    offlineIndexStore = db.get_object(session, 'offlineIndexStore')
    livePath = indexStore.get_path(session, 'defaultPath')
    offlinePath = offlineIndexStore.get_path(session, 'defaultPath')
    for name in os.listdir(offlinePath):
        fullPath = os.path.join(offlinePath, name)
        fullLivePath = os.path.join(livePath, name)
        if name in ['.gitignore', 'temp']:
            continue
        elif os.path.isdir(fullPath):
            # Remove existing live index
            shutil.rmtree(fullLivePath)
            shutil.move(fullPath, fullLivePath)
        elif os.path.isfile(fullPath):
            shutil.move(fullPath, fullLivePath)


def background_index(args):
    """Index pre-loaded EAD records in the background."""
    global session, db
    lgr = session.logger
    start = time.time()
    # Get the IndexStore and offlineIndexStore
    indexStore = db.get_object(session, 'indexStore')
    offlineIndexStore = db.get_object(session, 'offlineIndexStore')
    # Make the offlineIndexStore think it's the main one for the purposes of
    # file naming
    offlineIndexStore.id = 'indexStore'
    # Get the Indexes
    if not db.indexes:
        db._cacheIndexes(session)
    for idx in db.indexes.itervalues():
        # For those Indexes that will be added to
        # i.e. not creation date / modification date
        if not idx.get_setting(session, 'noIndexDefault', 0):
            # Modify the in-memory Index objects to store into offline
            # IndexStore
            idx.indexStore = offlineIndexStore
            idx.paths['indexStore'] = offlineIndexStore

    if args.step == 'index':
        # Clear existing indexes
        for idx in db.indexes.itervalues():
            if not idx.get_setting(session, 'noIndexDefault', 0):
                idx.clear(session)

        lgr.log_info(session,
                     "Indexing pre-loaded records into background indexes..."
                     )
        _index(session, db, args)

    allPassed = False
    # Only conduct search testing if necessary
    if args.step == 'test' or (args.step == 'index' and args.test):
        lgr.log_info(session,
                     "Testing background indexes..."
                     )
        allPassed = test_expectedResults(args)

    if (args.step == 'finalize' or
        (args.finalize and (allPassed or not args.test))
    ):
        lgr.log_info(session,
                     "Finalizing background indexes (making them live)..."
                     )
        commit_backgroundIndexing(args)
    else:
        offlinePath = offlineIndexStore.get_path(session, 'defaultPath')
        lgr.log_warning(session,
                        'Not replacing existing indexes; new indexes remain '
                        'in {0}'.format(offlinePath)
                        )
    # Log completed message
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(
        session, 
        'Background indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
        ''.format(hours, mins, secs)
    )
    return 0


def live_index(args):
    """Index pre-loaded EAD records into live indexes."""
    global session, db
    lgr = session.logger
    lgr.log_info(session,
                 "Indexing pre-loaded records into live indexes..."
                 )
    start = time.time()
    if args.step == 'index':
        # Clear the existing Indexes
        db.clear_indexes(session)
        _index(session, db, args)
    if args.test:
        test_expectedResults(args)
    # Log completed message
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(
        session, 
        'Live indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
        ''.format(hours, mins, secs)
    )
    return 0


def clusters(args):
    """Load and index subject clusters."""
    global session, db
    lgr = session.logger
    lgr.log_info(session, 'Accumulating subject clusters...')
    start = time.time()
    recordStore = db.get_object(session, 'recordStore')
    clusDocFac = db.get_object(session, 'clusterDocumentFactory')
    for rec in recordStore:
        clusDocFac.load(session, rec)
    session.database = '{0}_cluster'.format(session.database)
    clusDb = server.get_object(session, session.database)
    # Remove existing live index
    clusDb.clear_indexes(session)
    clusFlow = clusDb.get_object(session, 'buildClusterWorkflow')
    clusFlow.process(session, clusDocFac)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(
        session,
        'Subject Clustering complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
        ''.format(hours, mins, secs)
    )
    # return session.database to the default (finding aid) DB
    session.database = db.id
    return 0


def main(argv=None):
    global argparser
    global session, server, db
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    try:
        session, server, db = getCheshire3Env(args)
    except (EnvironmentError, ObjectDoesNotExistException):
        return 1
    # Set Logger
    with db.get_object(session, 'indexLogger') as session.logger:
        mp = db.get_path(session, 'metadataPath')
        lock = FileLock(mp)
        if lock.is_locked() and args.unlock:
            # Forcibly unlock
            session.logger.log_warning(session, "Unlocking Database")
            lock.break_lock()
        try:
            lock.acquire(timeout=10)    # Wait up to 10 seconds
        except LockTimeout:
            msg = ("The database is locked. It is possible that another "
                   "user is currently indexing this database. Please wait at "
                   "least 10 minutes and then try again. If you continue to "
                   "get this message and you are sure no one is reindexing "
                   "the database please contact the archives hub team for "
                   "advice."
                   )
            session.logger.log_critical(session, msg)
            return 1
        try:
            if args.clusters:
                return sum([args.func(args), clusters(args)])
            else:
                return args.func(args)
        finally:
            lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = IndexArgumentParser(conflict_handler='resolve',
                                description=docbits[0]
                                )

# Subparsers for commands
subparsers = argparser.add_subparsers(title='Commands',
                                      help="Build live or background Indexes")
# index.py background
parser_bg = subparsers.add_parser(
    "background",
    help=("load into offline indexes, replace live indexes when complete")
)
parser_bg.add_argument('--step',
                       choices=['index', 'test', 'finalize'],
                       default='index'
                       )
parser_bg.add_argument("-T", "--no-test",
                       action="store_false", dest="test",
                       help=("skip testing new indexes when indexing in "
                             "background mode. By default, tests must "
                             "pass before new indexes replace live ones in "
                             "this mode."
                             )
                       )
parser_bg.add_argument("-F", "--no-finalize",
                       action="store_false", dest="finalize",
                       help=("skip finalizing offline indexes; make them live"
                             )
                       )
parser_bg.set_defaults(func=background_index)
# index.py live
parser_live = subparsers.add_parser(
    "live",
    help=("load directly into the live indexes. not recommended for "
          "production use"
          )
)
parser_live.add_argument('--step',
                         choices=['index', 'test'],
                         default='index'
                         )
parser_live.add_argument("-T", "--no-test",
                         action="store_false", dest="test",
                         help=("skip testing new indexes"
                               )
                         )
parser_live.set_defaults(func=live_index)


if __name__ == '__main__':
    sys.exit(main())
