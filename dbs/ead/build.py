#!/bin/env python
# -*- coding: utf-8 -*-
#
# Script:    build.py
# Date:      7 May 2013
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Build the Cheshire3 for Archives database of EAD finding aid documents.

usage: build.py [-h] [-a] [-l] [-d DIR] [-c] [-s] [-i]
               [-x]

optional arguments:
  -h, --help            show this help message and exit
  -a, --all             load and index entire Cheshire3 for Archivessystem
                        (i.e. same as --load --components --cluster.) Excludes
                        all other operations.
  -l, --load            load and index EAD documents
  -d DIR, --data DIR    directory from which to load and index EAD documents
  -c, --components      load and index components from loaded EAD records
  -s, --subjects        load and index subject clusters
  -i, --index           index pre-loaded EAD records
  -x, --index-components
                        index pre-loaded component records
"""

import sys
import os
import time

from lockfile import FileLock

from cheshire3.commands.cmd_utils import identify_database

from archiveshub.commands.utils import BaseArgumentParser, getCheshire3Env


class LoadArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""
    
    def __init__(self, *args, **kwargs):
        super(LoadArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument("-a", "--all", 
                          action="store_true", dest="all",
                          default=False, 
                          help=("load and index entire Cheshire3 for Archives"
                                "system (i.e. same as --load --components "
                                "--cluster.) Excludes all other operations.")
                          )
        self.add_argument("-l", "--load",
                          action="store_true", dest="load",
                          default=False,
                          help="load and index EAD documents"
                          )
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        self.add_argument('data',
                          type=str, action='store', nargs='*',
                          metavar="DIR",
                          help=("directory from which to load and index EAD "
                                "documents")
                          )
        self.add_argument("-c", "--components", 
                          action="store_true", dest="components",
                          default=False, 
                          help=("load and index components from loaded EAD "
                                "records")
                          )
        self.add_argument("-s", "--subjects", 
                          action="store_true", dest="clusters",
                          default=False, 
                          help="load and index subject clusters"
                          )
        self.add_argument("-i", "--index", 
                          action="store_true", dest="index",
                          default=False, 
                          help="index pre-loaded EAD records"
                          )
        self.add_argument("-x", "--index-components", 
                          action="store_true", dest="index_components",
                          default=False,
                          help="index pre-loaded component records"
                          )

    def parse_args(self, args=None, namespace=None):
        args = super(LoadArgumentParser, self).parse_args(args, namespace)
        # Sanity checking for load
        args.load = bool(args.load or 
                         args.data or
                         not any([args.components,
                                  args.clusters,
                                  args.index,
                                  args.index_components])
                         )
        return args


def clusters(args):
    """Load and index subject clusters."""
    global session, db, lgr
    lgr.log_info(session, 'Accumulating subject clusters...')
    start = time.time()
    recordStore = db.get_object(session, 'recordStore')
    clusDocFac = db.get_object(session, 'clusterDocumentFactory')
    for rec in recordStore:
        clusDocFac.load(session, rec)
    
    session.database = '{0}_cluster'.format(session.database)
    clusDb = server.get_object(session, session.database)
    clusDb.clear_indexes(session)
    clusFlow = clusDb.get_object(session, 'buildClusterWorkflow')
    clusFlow.process(session, clusDocFac)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Subject Clustering complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, 
                                                                       mins, 
                                                                       secs)
                 )
    # return session.database to the default (finding aid) DB
    session.database = db.id
    return 0


def _conditional_load(args):
    # Check arguments and call necessary load methods
    if args.all:
        # if exclusive --all option
        # sum return values - should all return 0
        retval = sum([load(args),
                      components(args),
                      clusters(args)
                     ])
        return retval
    
    # Check individual load args
    retval = 0
    if args.load:
        retval += load(args)
    elif args.index:
        retval += index(args)
    
    # Components
    if args.components:
        retval += components(args)
    elif args.index_components:
        retval += index_components(args)
    
    # Subject clusters    
    if args.clusters:
        retval += clusters(args)
        
    return retval


def main(argv=None):
    global argparser, lockfilepath, lgr
    global session, server, db, lgr
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    try:
        session, server, db = getCheshire3Env(args)
    except (EnvironmentError, ObjectDoesNotExistException):
        return 1
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
        _conditional_load(args)
    finally:
        lock.release()
    
    
# Init OptionParser
docbits = __doc__.split('\n\n')
argparser = LoadArgumentParser(conflict_handler='resolve',
                              description=docbits[0]
                              )

if __name__ == '__main__':
    sys.exit(main())
