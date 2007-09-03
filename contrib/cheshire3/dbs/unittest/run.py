#!/home/cheshire/install/bin/python -i

import time, sys, os
osp = sys.path
sys.path = ["../../code"]
sys.path.extend(osp)

from baseObjects import Session
from server import SimpleServer
import PyZ3950
from PyZ3950.CQLParser import parse
from document import StringDocument

# Build environment...
session = Session()
serv = SimpleServer(session, "../../configs/serverConfig.xml")
db = serv.get_object(session, 'db_test')
session.database = 'db_test'
dfp = db.get_path(session, "defaultPath")

lxml = db.get_object(session, 'LxmlParser')
recStore = db.get_object(session, 'testRecordStore')
df = db.get_object(session, 'defaultDocumentFactory')

idx = db.get_object(session, 'idx-text-kwd-stem')
idxStore = db.get_object(session, 'testIndexStore')



if '-load' in sys.argv:
    db.begin_indexing(session)
    recStore.begin_storing(session)

    df.load(session, 'data', cache=0, format='dir')
    for doc in df:
        rec = lxml.process_document(session, doc)
        recStore.create_record(session, rec)
        db.add_record(session, rec)
        db.index_record(session, rec)
    
    recStore.commit_storing(session)
    db.commit_indexing(session)
    db.commit_metadata(session)

if '-load2' in sys.argv:
    # Commit more data to existing store
    db.begin_indexing(session)
    recStore.begin_storing(session)

    df.load(session, 'data2', cache=0, format='dir')
    for doc in df:
        rec = lxml.process_document(session, doc)
        recStore.create_record(session, rec)
        db.add_record(session, rec)
        db.index_record(session, rec)
    
    recStore.commit_storing(session)
    db.commit_indexing(session)
    db.commit_metadata(session)

if '-load3' in sys.argv:
    # Commit single extra record to existing without batch.

    recStore.begin_storing(session)
    df.load(session, 'record40.xml', cache=0, format='xml')
    for doc in df:
        rec = lxml.process_document(session, doc)
        recStore.create_record(session, rec)
        db.add_record(session, rec)
        db.index_record(session, rec)
    recStore.commit_storing(session)
    db.commit_metadata(session)

    
if '-del' in sys.argv:
    rec = recStore.fetch_record(session, 0)
    db.remove_record(session, rec)	
    db.unindex_record(session, rec)
    recStore.delete_record(session, rec)



# Test that all of our server level objects at least build
if '-configs' in sys.argv:
    for k in serv.subConfigs.keys():
        try:
            serv.get_object(session, k)
        except Exception, err:
            print k
            print err
            continue
