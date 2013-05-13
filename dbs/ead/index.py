# -*- coding: utf-8 -*-
# Script:    index.py
# Date:      13 May 2013
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Index the Archives Hub database of EAD finding aid documents.

usage: index.py [-h] [-s PATH] [-d DATABASE] [-l | -b | -o]

optional arguments:
  -h, --help            show this help message and exit
  -s PATH, --server-config PATH
                        path to Cheshire3 server configuration file. default: 
                        /home/cheshire/cheshire3/cheshire3/configs/serverConfi
                        g.xml
  -d DATABASE, --database DATABASE
                        identifier of Cheshire3 database
  -l, --live            load directly into the live indexes.not recommended
                        for production use
  -b, --background      load into offline indexes, replace live indexes when
                        complete (default)
  -o, --offline         load into offline indexes for manual checking

"""
import os
import shutil
import sys
import time

from lockfile import FileLock, LockTimeout

from archiveshub.commands.utils import BaseArgumentParser, getCheshire3Env


class IndexArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        super(IndexArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        group = self.add_mutually_exclusive_group()
        group.set_defaults(mode='background')
        group.add_argument("-l", "--live",
                           action='store_const',
                           dest='mode',
                           const='live',
                           help=("load directly into the live indexes."
                                 "not recommended for production use")
                           )
        group.add_argument("-b", "--background",
                           action='store_const',
                           dest='mode',
                           const='background',
                           help=("load into offline indexes, replace live "
                                 "indexes when complete (default)")
                           )
        group.add_argument("-o", "--offline",
                           action='store_const',
                           dest='mode',
                           const='offline',
                           help=("load into offline indexes for manual "
                                 "checking")
                           )


def _index_recordStore(recordStore):
    # Index all Records in a RecordStore
    global session, db
    lgr = session.logger
    for rec in recordStore:
        try:
            db.index_record(session, rec)
        except UnicodeDecodeError:
            lgr.log_error(
                session, 
                '{0.id:<40} [ERROR] - Some indexes not built; non unicode '
                'characters'.format(rec)
            )
        else:
            lgr.log_info(
                session, 
                '{0.id:<40} [OK]'.format(rec)
            )

def index(args):
    """Index pre-loaded EAD records."""
    global session, db
    lgr = session.logger
    lgr.log_info(session, "Indexing pre-loaded records...")
    start = time.time()
    if args.mode == "live":
        # Clear the existing Indexes
        db.clear_indexes(session)
    else:
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
                # Modify the in-memory Index objects to store into offline IndexStore
                idx.indexStore = offlineIndexStore
                idx.paths['indexStore'] = offlineIndexStore
                # Make sure Index is empty
                idx.clear(session)
    # Index Records
    db.begin_indexing(session)
    _index_recordStore(db.get_object(session, 'recordStore'))
    _index_recordStore(db.get_object(session, 'componentStore'))
    db.commit_indexing(session)
    db.commit_metadata(session)
    if args.mode == 'background':
        # TODO: Test search new indexes
        # Commit new indexes in place of old
        lgr.log_debug(session, 'Replacing existing indexes')
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
                shutil.copytree(fullPath, fullLivePath)
            elif os.path.isfile(fullPath):
                shutil.copy2(fullPath, fullLivePath)
    # Log completed message
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(
        session, 
        'Indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours,
                                                                mins,
                                                                secs)
    )
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
    # TODO: Set default log level to INFO
    session.logger.minLevel = 10
    mp = db.get_path(session, 'metadataPath')
    lock = FileLock(mp)
    try:
        lock.acquire(timeout=5)    # wait up to 30 seconds
    except LockTimeout:
        msg = ("The database is locked. It is possible that another "
               "user is currently indexing this database. Please wait at least" 
               " 10 minutes and then try again. If you continue to get this "
               "message and you are sure no one is reindexing the database "
               "please contact the archives hub team for advice."
               )
        session.logger.log_critical(session, msg)
        return 1
    try:
        return index(args)
    finally:
        lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = IndexArgumentParser(conflict_handler='resolve',
                                description=docbits[0]
                                )


if __name__ == '__main__':
    sys.exit(main())
