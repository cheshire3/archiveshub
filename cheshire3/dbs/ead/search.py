#!/home/cheshire/cheshire3/install/bin/python -i

import sys, os
from lxml import etree

osp = sys.path
sys.path = ["../../code", "../../www/ead"]
sys.path.extend(osp)

from baseObjects import Session
from server import SimpleServer
from document import StringDocument
from PyZ3950 import CQLParser
from utils import flattenTexts
import c3errors

def _backwalkTitles(rec, path):
    titles = []
    pathParts = path.split('/')
    while pathParts[-1] != 'dsc':
        try:
            t = rec.process_xpath('/'.join(pathParts) + '/did/unittitle')[0]
            t = flattenTexts(t)
            titles.append(t.strip())
        except IndexError:
            print etree.dump(rec.process_xpath('/'.join(pathParts) + '/did')[0])
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
    qString = 'dc.description all/relevant/proxinfo "money"'

q = CQLParser.parse(qString)
rs = db.search(session, q)
hits = len(rs)
print hits, 'hits'
parents = {}
for x in range(min(5, hits)):
    rec = rs[x].fetch_record(session)
    try:
        parId = rec.process_xpath('/c3component/@parent')[0]
        parId = parId.split('/')[-1]
    except IndexError:
        titles = [rec.process_xpath('/*/*/did/unittitle/text()')[0]]
    else:
        parRec = recordStore.fetch_record(session, parId)
        xpath = rec.process_xpath('/c3component/@xpath')[0]
        titles = _backwalkTitles(parRec, xpath)
        
    for y, t in enumerate(titles):
        print (' ' * (y*2)) + t
    