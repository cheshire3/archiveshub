#!/bin/env python
#
# Script:    run.py
# Date:      13 November 2012
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Load the Cheshire3 for Archives database of EAD finding aid documents.

Usage: load.py [options]

Options:
  -h, --help            show this help message and exit
  -a, --all             load and index entire Cheshire3 for Archives system
                        (i.e. same as --load --components --cluster.) Excludes
                        all other operations.
  -l, --load            load and index EAD documents
  -d DIR, --data=DIR    directory from which to load and index EAD documents
  -c, --components      load and index components from loaded EAD records
  -s, --clusters        load and index subject clusters
  -i, --index           index pre-loaded EAD records
  -x, --index-components
                        index pre-loaded component records
"""

import sys
import os
import time

from optparse import OptionParser, OptionGroup

from run import UsageException
from run import session, serv, db, recordStore, clusDb

class EADOptionParser(OptionParser):
    """Custom option parser for Cheshire3 for Archives management."""
    def __init__(self, **kwargs):
        OptionParser.__init__(self, **kwargs)
        self.add_option(
            "-a", "--all", 
            action="store_true", dest="all", default=False, 
            help="""load and index entire Cheshire3 for Archives system (i.e.\
 same as --load --components --cluster.) Excludes all other operations.""")
        self.add_option(
            "-l", "--load", 
            action="store_true", dest="load", default=False,
            metavar="DIR", 
            help="load and index EAD documents")
        self.add_option(
            "-d", "--data", 
            action="store", type="string", dest="data", default=None,
            metavar="DIR", 
            help="directory from which to load and index EAD documents")
        self.add_option(
            "-c", "--components", 
            action="store_true", dest="components", default=False, 
            help="load and index components from loaded EAD records")
        self.add_option(
            "-s", "--clusters", 
            action="store_true", dest="clusters", default=False, 
            help="load and index subject clusters")
        self.add_option(
            "-i", "--index", 
            action="store_true", dest="index", default=False, 
            help="index pre-loaded EAD records")
        self.add_option(
            "-x", "--index-components", 
            action="store_true", dest="index_components", default=False, 
            help="index pre-loaded component records")

    def parse_args(self, args=None, values=None):
        (options, args) = OptionParser.parse_args(self, args, values)
        # Sanity checking for load
        options.load = bool(options.load or 
                            options.data is not None or
                            not any([options.components,
                                     options.clusters,
                                     options.index,
                                     options.index_components])
                            )
        return (options, args)



def load(options, args):
    """Load and index EAD documents."""
    global session, db
    lgr.log_info(session, 'Loading and indexing...')
    db.clear_indexes(session)
    start = time.time()
    # build necessary objects
    flow = db.get_object(session, 'buildIndexWorkflow')
    baseDocFac = db.get_object(session, 'baseDocumentFactory')
    baseDocFac.load(session, options.data)
    lgr.log_info(session, 'Loading files from {0}...'.format(baseDocFac.dataPath))
    flow.load_cache(session, db)
    flow.process(session, baseDocFac)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Loading, Indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, 
                                                                   mins, 
                                                                   secs)
                 )
    return 0


def index(options, args):
    """Index pre-loaded EAD records."""
    global session, db, lgr
    lgr.log_info(session, "Indexing pre-loaded records...")
    start = time.time()
    if not db.indexes:
        db._cacheIndexes(session)
    for idx in db.indexes.itervalues():
        if not idx.get_setting(session, 'noUnindexDefault', 0):
            idx.clear(session)
    db.begin_indexing(session)
    for rec in recordStore:
        try:
            db.index_record(session, rec)
        except UnicodeDecodeError:
            lgr.log_error(session, 
                          rec.id.ljust(40) + ' [ERROR] - Some indexes not built; non unicode characters')
        else:
            lgr.log_info(session, 
                         rec.id.ljust(40) + ' [OK]')
        del rec
     
    db.commit_indexing(session)
    db.commit_metadata(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, 
                                                             mins, 
                                                             secs)
                 )
    return 0


def components(options, args):
    """Load and index components from loaded EAD records."""
    global session, lgr, db, recordStore
    lgr.log_info(session, 'Loading and indexing components...')
    start = time.time()
    compFlow = db.get_object(session, 'buildAllComponentWorkflow')
    compFlow.load_cache(session, db)
    compFlow.process(session, recordStore)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Components loaded and indexed ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, 
                                                                         mins, 
                                                                         secs)
                 )
    return 0


def index_components(options, args):
    """Index pre-loaded component records."""
    global lgr, session, db, componentStore
    lgr.log_info(session, "Indexing components...")
    start = time.time()
    db.begin_indexing(session)
    parent = ''
    for rec in componentStore:
        try:
            db.index_record(session, rec)
        except UnicodeDecodeError:
            lgr.log_error(session, 
                          rec.id.ljust(40) + ' [ERROR] - Some indexes not built; non unicode characters')
        else:
            lgr.log_info(session, 
                          rec.id.ljust(40) + ' [OK]')  
        del rec
            
    db.commit_indexing(session)
    db.commit_metadata(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    lgr.log_info(session, 
                 'Component Indexing complete ({0:.0f}h {1:.0f}m {2:.0f}s)'.format(hours, 
                                                                       mins, 
                                                                       secs)
                 )
    return 0


def clusters(options, args):
    """Load and index subject clusters."""
    global session, lgr, recordStore, clusDb
    lgr.log_info(session, 'Accumulating subject clusters...')
    start = time.time()
    for rec in recordStore:
        clusDocFac.load(session, rec)
    
    session.database = clusDb.id
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


def _conditional_load(options, args):
    # Check options and call necessary load methods
    if options.all:
        # if exclusive --all option
        # sum return values - should all return 0
        retval = sum([load(options, args),
                      components(options, args),
                      clusters(options, args)
                     ])
        return retval
    
    # Check individual load args
    retval = 0
    if options.load:
        retval += load(options, args)
    elif options.index:
        retval += index(options, args)
    
    # Components
    if options.components:
        retval += components(options, args)
    elif options.index_components:
        retval += index_components(options, args)
    
    # Subject clusters    
    if options.clusters:
        retval += clusters(options, args)
        
    return retval


def main(argv=None):
    global option_parser, lockfilepath, lgr
    if argv is None:
        argv = sys.argv[1:]
    try:
        (options, args) = option_parser.parse_args(argv)
    except UsageException as err:
        option_parser.print_usage(file=sys.stderr)
        print >>sys.stderr, str(err)
        print >>sys.stderr, "for help use --help"
        return 1
    if os.path.exists(lockfilepath):
        lgr.log_critical(session, 
                         '''\
ERROR: Another user is currently indexing this database. Please wait at least 
10 minutes and then try again.

If you continue to get this message and you are sure no one is reindexing the 
database please contact the archives hub team for advice.''')   
        sys.exit(1)
    else:
        lock = open(lockfilepath, 'w')
        lock.close()
    try:
        _conditional_load(options, args)
    finally:
        if os.path.exists(lockfilepath):
            os.remove(lockfilepath)
    
    
# Init OptionParser
docbits = __doc__.split('\n\n')
option_parser = EADOptionParser(description=docbits[0])

# Lock file
lockfilepath = os.path.join(db.get_path(session, 'defaultPath'), 
                            'indexing.lock')

lgr = db.get_path(session, 'defaultLogger')
componentStore = db.get_object(session, 'componentStore')
clusDocFac = db.get_object(session, 'clusterDocumentFactory')

if __name__ == '__main__':
    sys.exit(main())
