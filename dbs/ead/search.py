#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Script:    search.py
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
"""Search the Archives Hub database.

usage: search.py [-h] [-s PATH] [--version] [-d DATABASE] [-c]
                 query [query ...]

Search the Archives Hub database.

positional arguments:
  query                 keywords to search for or CQL query to run

optional arguments:
  -h, --help            show this help message and exit
  -s PATH, --server-config PATH
                        path to Cheshire3 server configuration file. default: 
                        /home/cheshire/git/cheshire3/cheshire3/configs/serverC
                        onfig.xml
  --version             show program's version number and exit
  -d DATABASE, --database DATABASE
                        identifier of Cheshire3 database
  -c, --cql             parse input as CQL rather than keywords. When using
                        this option it is important to provide the CQL query
                        as a single string argument (i.e. surrounded by quotes
                        with internal quotes escaped as necessary)

Search the Archives Hub database of EAD finding aid documents to find matches
for keywords, or the CQL query supplied.


Search the Archives Hub database of EAD finding aid documents to find matches
for keywords, or the CQL query supplied.
"""

import sys
import os
import time

from lxml import etree

from cheshire3.document import StringDocument
from cheshire3.exceptions import (
    ObjectDeletedException,
    ObjectDoesNotExistException
)
from cheshire3.utils import flattenTexts


from archiveshub.apps.ead.base import cleverTitleCase
from archiveshub.deploy.utils import BaseArgumentParser, getCheshire3Env


class SearchArgumentParser(BaseArgumentParser):
    """Custom option parser for Archives Hub search."""

    def __init__(self, *args, **kwargs):
        super(SearchArgumentParser, self).__init__(*args, **kwargs)
        self.add_argument('-d', '--database',
                          type=str, action='store', dest='database',
                          default=None, metavar='DATABASE',
                          help="identifier of Cheshire3 database")
        self.add_argument('-c', '--cql',
                          action='store_true', dest='cql',
                          help=("parse input as CQL rather than keywords. "
                                "When using this option it is important to "
                                "provide the CQL query as a single string "
                                "argument (i.e. surrounded by quotes with "
                                "internal quotes escaped as necessary)")
                          )
        self.add_argument('query',
                          nargs='+',
                          action='store',
                          help=("keywords to search for or CQL query to run")
                          )


def _backwalkTitles(rec, xpath):
    titles = []
    xpathParts = xpath.split('/')
    while xpathParts[-1] != 'dsc':
        try:
            tn = rec.process_xpath(session,
                                   '/'.join(xpathParts) + '/did/unittitle'
                                   )[0]
            t = flattenTexts(tn)
            titles.append(t.strip())
        except IndexError:
            print etree.dump(
                rec.process_xpath(session,
                                  '/'.join(xpathParts) + '/did'
                                  )[0]
                )
            raise

        xpathParts.pop(-1)

    titles.reverse()
    return titles


def _backwalkTitles2(rec, xpath):
    node = rec.get_dom(session).xpath(xpath)[0]
    titles = [node.xpath('string(./did/unittitle)')]
    for n in node.iterancestors():
        if n.tag == 'dsc':
            continue
        elif n.tag == 'ead':
            break
        t = n.xpath('string(./did/unittitle)')
        titles.append(t.strip())

    titles.reverse()
    return titles


def doSearch(qString):
    global db, qf, recordStore
    q = qf.get_query(session, qString)
    rs = db.search(session, q)
    hits = len(rs)
    print hits, 'hits'
    for i, rsi in enumerate(rs[:min(5, hits)], start=1):
        try:
            rec = rsi.fetch_record(session)
        except ObjectDeletedException:
            titles = ['This record has been deleted']
        else:
            try:
                parId = rec.process_xpath(session, '/c3component/@parent')[0]
                parId = parId.partition('/')[2]
            except IndexError:
                titles = [rec.process_xpath(session,
                                            '/*/*/did/unittitle/text()')[0]
                          ]
            else:
                parRec = recordStore.fetch_record(session, parId)
                xpath = rec.process_xpath(session, '/c3component/@xpath')[0]
                titles = _backwalkTitles2(parRec, xpath)

        print i,
        for y, t in enumerate(titles):
            if y:
                print ' ',
            print (' ' * (y * 2)), t
    return rs


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
    recordStore = db.get_object(session, 'recordStore')

    terms = ' '.join(args.query)
    if args.cql:
        session.logger.log_debug(session,
                                 'Executing CQL: {0}'.format(terms)
                                 )
        qString = terms
    else:
        # Treat as keywords
        session.logger.log_debug(session,
                                 'Searching for all keywords "{0}"'
                                 ''.format(terms)
                                 )
        qString = ('(cql.anywhere all/relevant/proxinfo "{0}") '
                   'or/relevant/proxinfo '
                   '(dc.description all/relevant/proxinfo "{0}") '
                   'or/relevant/proxinfo '
                   '(dc.title all/relevant/proxinfo "{0}")'
                   ''.format(terms))
    doSearch(qString)


# Init ArgParser
docbits = __doc__.split('\n\n')
argparser = SearchArgumentParser(conflict_handler='resolve',
                                 description=docbits[0],
                                 epilog=docbits[-1]
                                 )


if __name__ == '__main__':
    sys.exit(main())
