#!/home/cheshire/install/bin/python -i
## Script:    search.py
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

import sys, os, time
from lxml import etree

sys.path.insert(1, "../../www/ead")
sys.path.insert(1, "../../code")

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer
from cheshire3.document import StringDocument
from cheshire3.utils import flattenTexts
from cheshire3 import exceptions as c3errors

def _backwalkTitles(rec, xpath):
    titles = []
    xpathParts = xpath.split('/')
    while xpathParts[-1] != 'dsc':
        try:
            tn = rec.process_xpath(session, '/'.join(xpathParts) + '/did/unittitle')[0]
            t = flattenTexts(tn)
            titles.append(t.strip())
        except IndexError:
            print etree.dump(rec.process_xpath(session, '/'.join(xpathParts) + '/did')[0])
            raise
            
        xpathParts.pop(-1)
        
    titles.reverse()
    return titles

def _backwalkTitles2(rec, xpath):
    node = rec.get_dom(session).xpath(xpath)[0]
    titles = [node.xpath('string(./did/unittitle)')]
    for n in node.iterancestors():
        if n.tag == 'dsc': continue
        elif n.tag == 'ead': break
        t = n.xpath('string(./did/unittitle)')
        titles.append(t.strip())
#        try:
#            tn = n.xpath('did/unittitle')[0]
#        except IndexError:
#            print etree.dump(n.xpath('did'))
#            raise
#        else:
#            t = flattenTexts(tn)
#            titles.append(t.strip())
    
    titles.reverse()
    return titles


def doSearch(qString):
    q = qf.get_query(session, qString)
    rs = db.search(session, q)
    hits = len(rs)
    print hits, 'hits'
    parents = {}
    for i, rsi in enumerate(rs[:min(5, hits)]):
        rec = rsi.fetch_record(session)
        try:
            parId = rec.process_xpath(session, '/c3component/@parent')[0]
            parId = parId.split('/')[-1]
        except IndexError:
            titles = [rec.process_xpath(session, '/*/*/did/unittitle/text()')[0]]
        else:
            parRec = recordStore.fetch_record(session, parId)
            xpath = rec.process_xpath(session, '/c3component/@xpath')[0]
            titles = _backwalkTitles2(parRec, xpath)
        
        print i,
        for y, t in enumerate(titles):
            if y:
                print ' ',
            print (' ' * (y*2) ),t
    return rs

# Build environment...
session = Session()
serv = SimpleServer(session, "../../configs/serverConfig.xml")
session.database = 'db_ead'
db = serv.get_object(session, 'db_ead')
recordStore = db.get_object(session, 'recordStore')
rss = db.get_object(session, 'eadResultSetStore')
qf = db.get_object(session, 'defaultQueryFactory')

if len(sys.argv[1:]):
    qString = ' '.join(sys.argv[1:])
else:
    qString = 'cql.anywhere all/relevant/proxinfo "money"'
    qString = '((cql.anywhere all/relevant/proxinfo "money") or/relevant/proxinfo (dc.description all/relevant/proxinfo "money") or/relevant/proxinfo (dc.title all/relevant/proxinfo "money"))'
doSearch(qString)

    
