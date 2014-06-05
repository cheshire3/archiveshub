#!/bin/env python
# -*- coding: utf-8 -*-
# Script:    browse.py
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
"""Browse the Archives Hub Indexes.

"""

import sys

from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.apps.ead.base import cleverTitleCase
from archiveshub.deploy.utils import BaseArgumentParser, getCheshire3Env


class BrowseArgumentParser(BaseArgumentParser):
    """Custom option parser for Archives Hub browsing."""

    def __init__(self, *args, **kwargs):
        super(BrowseArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        self.add_argument('-r', '--relation',
                          type=str, action='store', dest='relation',
                          default='exact',
                          help=("CQL relation")
                          )
        self.add_argument('-n', '--maximum-terms',
                          type=int, dest='nTerms',
                          default=25, metavar='MAXIMUM_TERMS',
                          help=("maximum number of terms to display")
                          )
        self.add_argument('-p', '--position',
                          type=int, dest='responsePosition',
                          default=1, metavar='POSITION',
                          help=("position of requested term in response")
                          )
        self.add_argument('index',
                          help=("Index to scan")
                          )
        self.add_argument('term',
                          help=("Index to scan")
                          )


def fetch_scanData(scanClause, maximumTerms=25, rp=1):
    if (rp == 0):
        scanData = db.scan(session,
                           scanClause,
                           maximumTerms,
                           direction=">"
                           )
        if (len(scanData) < maximumTerms):
            hitend = True
    elif (rp == 1):
        scanData = db.scan(session,
                           scanClause,
                           maximumTerms,
                           direction=">="
                           )
        if (len(scanData) < maximumTerms):
            hitend = True
    elif (rp == maximumTerms):
        scanData = db.scan(session,
                           scanClause,
                           maximumTerms,
                           direction="<="
                           )
        scanData.reverse()
        if (len(scanData) < maximumTerms):
            hitstart = True
    elif (rp == maximumTerms + 1):
        scanData = db.scan(session,
                           scanClause,
                           maximumTerms,
                           direction="<"
                           )
        scanData.reverse()
        if (len(scanData) < maximumTerms):
            hitstart = True
    else:
        # We ask for 1 extra term and trim it off later to check if there
        # are more terms (for navigation purposes)
        # Need to go up...
        try:
            scanData = db.scan(session,
                               scanClause,
                               rp + 1,
                               direction="<="
                               )
        except:
            scanData = []
        if (len(scanData) < rp + 1):
            hitstart = True
        else:
            scanData.pop(-1)
        # ... then down
        try:
            scanData1 = db.scan(session,
                                scanClause,
                                (maximumTerms - rp + 1) + 1,
                                direction=">="
                                )
        except:
            scanData1 = []

        if (len(scanData1) < (maximumTerms - rp + 1) + 1):
            hitend = True
        else:
            scanData1.pop(-1)
        # Try to stick them together
        try:
            if scanData1[0][0] == scanData[0][0]:
                scanTermNorm = scanData.pop(0)[0]
            else:
                scanData.insert(0, None)
                scanData.pop(-1)
                scanData1.pop(-1)
        except:
            pass
        scanData.reverse()
        scanData.extend(scanData1)
        del scanData1
    return scanData


def main(argv=None):
    global argparser
    global session, server, db, qf, recordStore
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    try:
        session, server, db = getCheshire3Env(args)
    except (EnvironmentError, ObjectDoesNotExistException):
        return 1
    qf = db.get_object(session, 'defaultQueryFactory')
    qString = u'%s %s "%s"' % (args.index, args.relation, args.term)
    try:
        scanClause = qf.get_query(session,
                                  qString,
                                  format="cql"
                                  )
    except:
        session.logger.log_critical(session,
                                    "Unparsable query {0}".format(qString)
                                    )
        return 1
    else:
        session.logger.log_debug(session,
                                 "Scanning query {0}".format(qString)
                                 )
    scanData = fetch_scanData(scanClause,
                              args.nTerms,
                              args.responsePosition
                              )
    for row in scanData:
        if row is None:
            print "'{0}' would have been here".format(args.term)
        else:
            print cleverTitleCase(row[0])


# Init ArgParser
docbits = __doc__.split('\n\n')
argparser = BrowseArgumentParser(conflict_handler='resolve',
                                 description=docbits[0],
                                 epilog=docbits[-1]
                                 )


if __name__ == '__main__':
    sys.exit(main())
