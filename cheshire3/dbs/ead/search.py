#!/home/cheshire/cheshire3/install/bin/python -i
#
# Script:    search.py
# Date:      11 February 2008
# Copyright: &copy; University of Liverpool 2005-2008
# Description:
#            Quick search testing script
#            - part of Cheshire for Archives v3
#
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
#
# Language:  Python
#

import sys, os
from lxml import etree

osp = sys.path
sys.path = ["../../code", "../../www/ead"]
sys.path.extend(osp)

from baseObjects import Session
from server import SimpleServer
from document import StringDocument
from PyZ3950.CQLParser import parse as CQLparse
from utils import flattenTexts
import c3errors

def _backwalkTitles(rec, path):
    titles = []
    pathParts = path.split('/')
    while pathParts[-1] != 'dsc':
        try:
            t = rec.process_xpath(session, '/'.join(pathParts) + '/did/unittitle')[0]
            t = flattenTexts(t)
            titles.append(t.strip())
        except IndexError:
            print etree.dump(rec.process_xpath(session, '/'.join(pathParts) + '/did')[0])
            raise
            
        pathParts.pop(-1)
        
    titles.reverse()
    return titles

# Build environment...
session = Session()
serv = SimpleServer(session, "../../configs/serverConfig.xml")
session.database = 'db_ead'
db = serv.get_object(session, 'db_ead')
recordStore = db.get_object(session, 'recordStore')

if len(sys.argv[1:]):
    qString = ' '.join(sys.argv[1:])
else:
    qString = 'cql.anywhere all/relevant/proxinfo "money"'

q = CQLparse(qString)
rs = db.search(session, q)
hits = len(rs)
print hits, 'hits'
parents = {}
for x in range(min(5, hits)):
    rec = rs[x].fetch_record(session)
    try:
        parId = rec.process_xpath(session, '/c3component/@parent')[0]
        parId = parId.split('/')[-1]
    except IndexError:
        titles = [rec.process_xpath(session, '/*/*/did/unittitle/text()')[0]]
    else:
        parRec = recordStore.fetch_record(session, parId)
        xpath = rec.process_xpath(session, '/c3component/@xpath')[0]
        titles = _backwalkTitles(parRec, xpath)
    
    print x+1,
    for y, t in enumerate(titles):
        if y: print ' ',
        print (' ' * (y*2) ),t
    