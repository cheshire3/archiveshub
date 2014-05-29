#!/bin/env python
# -*- coding: utf-8 -*-
# Script:    unload.py
# Copyright: &copy; University of Liverpool 2014-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Unload EAD Documents into the Archives Hub.

usage: unload.py [-h] [-s PATH] [-d DATABASE] [-m | -c | -x] [ID [ID ...]]

positional arguments:
  ID                    identifier for contributor(s) to unload

optional arguments:
  -h, --help            show this help message and exit
  -s PATH, --server-config PATH
                        path to Cheshire3 server configuration file. default:
                        /home/cheshire/cheshire3/cheshire3/configs/serverConfi
                        g.xml
  -d DATABASE, --database DATABASE
                        identifier of Cheshire3 database
  -m, --main, --no-components
                        unload only collection-level descriptions
  -c, --with-components
                        unload collections-level descriptions and components
                        (default)
  -x, --no-descriptions, --components-only
                        unload only components


Unload EAD finding aid documents from registered contributor(s) directories
into Cheshire3.
"""

import os
import sys
import time

from lockfile import FileLock, LockTimeout

from cheshire3.exceptions import (
    ObjectDeletedException,
    ObjectDoesNotExistException
)
from archiveshub.deploy.utils import BaseArgumentParser, getCheshire3Env


class UnloadArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        super(UnloadArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        group = self.add_mutually_exclusive_group()
        group.set_defaults(mode='both')
        group.add_argument("-c", "--with-components",
                           action='store_const',
                           dest='mode',
                           const='both',
                           help=("unload collections-level descriptions and "
                                 "components (default)")
                           )
        group.add_argument("-m", "--main", "--no-components",
                           action='store_const',
                           dest='mode',
                           const='main',
                           help=("unload only collection-level descriptions")
                           )
        group.add_argument("-x", "--no-descriptions", "--components-only",
                           action='store_const',
                           dest='mode',
                           const='components',
                           help=("unload only components")
                           )
        self.add_argument('identifier',
                          nargs='*',
                          action='store',
                          metavar="ID",
                          help=("identifier for contributor(s) to unload")
                          )


def _get_storeIterator(args):
    # Return an iterator for the DocumentStores to unload
    global session, db
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
                session.logger.log_error(
                    session,
                    "Contributor with identifier {0} does not seem to "
                    "exist. It's possible that the default identifier "
                    "for the directory was over-ridden with the --id "
                    "option - you'll need to specify the identifier "
                    "instead of the directory name".format(contributorId)
                )
    else:
        storeIterator = store
    return storeIterator


def unload(args):
    """Unload named contributor(s).

    Unload the Records for the named contributor(s) from the internal
    RecordStore.
    """
    global session, db
    session.logger.log_info(session, 'Unloading...')
    start = time.time()
    storeIterator = _get_storeIterator(args)
    recordStore = db.get_object(session, 'recordStore')
    queryFactory = db.get_object(session, 'defaultQueryFactory')
    modifiedIdx = db.get_object(session, 'idx-modificationDate')
    # Now iterate over the selected stores
    for contributorStore in storeIterator:
        query = queryFactory.get_query(session,
                                       'c3.idx-documentStore = "{0}"'
                                       ''.format(contributorStore.id)
                                       )
        contributorId = contributorStore.id[:-len('DocumentStore')]
        db.begin_indexing(session)
        recordStore.begin_storing(session)
        rs = db.search(session, query)
        for rsi in rs:
            try:
                rec = rsi.fetch_record(session)
            except ObjectDeletedException:
                continue
            modifiedIdx.index_record(session, rec)
            recordStore.delete_record(session, rec)
        recordStore.commit_storing(session)
        db.commit_indexing(session)
        session.logger.log_info(session,
                     "Description documents for {0} unloaded"
                     "".format(contributorId)
        )
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    session.logger.log_info(
        session,
        ('Description loading complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
         ''.format(hours, mins, secs))
         )
    return 0


def unload_components(args):
    """Unload components for the named contributor(s).

    Unload the Records for the named contributor(s) from the internal
    Component RecordStore.
    """
    global session, db
    session.logger.log_info(session, 'Unloading...')
    start = time.time()
    storeIterator = _get_storeIterator(args)
    componentStore = db.get_object(session, 'componentStore')
    queryFactory = db.get_object(session, 'defaultQueryFactory')
    modifiedIdx = db.get_object(session, 'idx-modificationDate')
    # Now iterate over the selected stores
    for contributorStore in storeIterator:
        contributorId = contributorStore.id[:-len('DocumentStore')]
        db.begin_indexing(session)
        componentStore.begin_storing(session)
        query = queryFactory.get_query(session,
                                       'c3.idx-documentStore = "{0}"'
                                       ''.format(contributorStore.id)
                                       )
        rs = db.search(session, query)
        for rsi in rs:
            comp_queryString = ('c3.idx-collectionid = "{0}" not '
                                'c3.idx-recid = "{0}"'.format(rsi.id))
            comp_query = queryFactory.get_query(session, comp_queryString)
            comp_rs = db.search(session, comp_query)
            # Delete all components for this Description
            for comp_rsi in comp_rs:
                try:
                    rec = comp_rsi.fetch_record(session)
                except ObjectDeletedException:
                    continue
                modifiedIdx.index_record(session, rec)
                try:
                    componentStore.delete_record(session, rec)
                except:
                    session.logger.log_warning(session,
                                               'Unable to delete Record {0}'
                                               ''.format(rec.id)
                                               )
        componentStore.commit_storing(session)
        db.commit_indexing(session)
        session.logger.log_info(
            session,
            "Components for {0} unloaded".format(contributorId)
        )
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    session.logger.log_info(
        session,
        'Component unloading completed ({0:.0f}h {1:.0f}m {2:.0f}s)'
        ''.format(hours, mins, secs)
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

    # Set Logger
    with db.get_object(session, 'loadLogger') as session.logger:
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
            if args.mode == "main":
                # Load only collection-level
                return unload(args)
            elif args.mode == "components":
                # Load only components
                return unload_components(args)
            else:
                # Load collection-level and components
                return int(any([unload_components(args),
                                unload(args)
                                ])
                           )
        finally:
            lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = UnloadArgumentParser(conflict_handler='resolve',
                                 description=docbits[0],
                                 epilog=docbits[-1]
                                 )
argparser.add_argument('-u', '--unlock', action='store_true',
                       dest='unlock',
                       help=("if the database is currently locked, force "
                             "unlock it before proceeding to requested "
                             "operation."
                            )
                       )

if __name__ == '__main__':
    sys.exit(main())
