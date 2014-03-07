#!/bin/env python
# -*- coding: utf-8 -*-
# Script:    load.py
# Date:      3 March 2014
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Load EAD Documents into the Archives Hub.

usage: load.py [-h] [-s PATH] [-d DATABASE] [-m | -c | -x] [ID [ID ...]]

positional arguments:
  ID                    identifier for contributor(s) to load

optional arguments:
  -h, --help            show this help message and exit
  -s PATH, --server-config PATH
                        path to Cheshire3 server configuration file. default:
                        /home/cheshire/cheshire3/cheshire3/configs/serverConfi
                        g.xml
  -d DATABASE, --database DATABASE
                        identifier of Cheshire3 database
  -m, --main, --no-components
                        load only collection-level descriptions
  -c, --with-components
                        load collections-level descriptions and components
                        (default)
  -x, --no-descriptions, --components-only
                        load only components


Load EAD finding aid documents from registered contributor directories into
Cheshire3.
"""

import os
import sys
import time

from lockfile import FileLock, LockTimeout

from cheshire3.baseObjects import Record
from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.apps.ead.base import cleverTitleCase
from archiveshub.deploy.utils import BaseArgumentParser, getCheshire3Env


class LoadArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        super(LoadArgumentParser, self).__init__(*args, **kwargs)
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
                           help=("load collections-level descriptions and "
                                 "components (default)")
                           )
        group.add_argument("-m", "--main", "--no-components",
                           action='store_const',
                           dest='mode',
                           const='main',
                           help=("load only collection-level descriptions")
                           )
        group.add_argument("-x", "--no-descriptions", "--components-only",
                           action='store_const',
                           dest='mode',
                           const='components',
                           help=("load only components")
                           )
        self.add_argument('identifier',
                          nargs='*',
                          action='store',
                          metavar="ID",
                          help=("identifier for contributor(s) to load")
                          )


def _get_storeIterator(args):
    # Return an iterator for the DocumentStores to load
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


def load(args):
    """Load named contributor(s).

    Load the Documents for the named contributor(s) into the internal
    RecordStore.
    """
    global session, db
    session.logger.log_info(session, 'Loading...')
    start = time.time()
    storeIterator = _get_storeIterator(args)
    # Now iterate over the selected stores
    wf = db.get_object(session, 'loadSingleWorkflow')
    recordStore = db.get_object(session, 'recordStore')
    title_idx = db.get_object(session, 'idx-title')
    for contributorStore in storeIterator:
        contributorId = contributorStore.id[:-len('DocumentStore')]
        db.begin_indexing(session)
        recordStore.begin_storing(session)
        collections = []
        for doc in contributorStore:
            rec = wf.process(session, doc)
            if not isinstance(rec, Record):
                # Record not successfully stored - do not list
                continue
            title = title_idx.extract_data(session, rec) or '(untitled)'
            collections.append((rec.id, cleverTitleCase(title)))
        recordStore.commit_storing(session)
        db.commit_indexing(session)
        session.logger.log_info(session,
                     "Description documents for {0} loaded"
                     "".format(contributorId)
        )
        # Store a list of collections
        fp = os.path.join(
            os.path.expanduser('~/mercurial'),
            'archiveshub',
            'htdocs',
            'permalinks',
            '{0}.html'.format(contributorId)
        )
        with open(fp, 'w') as fh:
            fh.write('<ul>\n')
            fh.writelines([
                u'<li><a href="/data/{0}">{1}</a></li>'.format(*c)
                for c
                in collections
            ])
        session.logger.log_info(session,
                                "Collections listed in {0}".format(fp)
                                )
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    session.logger.log_info(
        session,
        ('Description loading complete ({0:.0f}h {1:.0f}m {2:.0f}s)'
         ''.format(hours, mins, secs))
         )
    return 0


def load_components(args):
    """Load components for the named contributor(s).

    Load the Documents for the named contributor(s) into the internal
    Component RecordStore.
    """
    global session, db
    storeIterator = _get_storeIterator(args)
    session.logger.log_info(session, 'Loading components...')
    start = time.time()
    storeIterator = _get_storeIterator(args)
    for contributorStore in storeIterator:
        contributorId = contributorStore.id[:-len('DocumentStore')]
        wf = db.get_object(session, 'loadAllComponentsWorkflow')
        wf.process(session, contributorStore)
        session.logger.log_info(session,
                     "Components for {0} loaded"
                     "".format(contributorId)
        )
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    session.logger.log_info(session,
                 'Component loading completed ({0:.0f}h {1:.0f}m {2:.0f}s)'
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
                return load(args)
            elif args.mode == "components":
                # Load only components
                return load_components(args)
            else:
                # Load collection-level and components
                return int(any([load(args),
                                load_components(args)
                                ])
                           )
        finally:
            lock.release()


# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = LoadArgumentParser(conflict_handler='resolve',
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
