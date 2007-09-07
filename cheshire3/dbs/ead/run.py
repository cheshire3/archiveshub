#!/home/cheshire/cheshire3/install/bin/python

import time, sys, os, re, getpass, traceback
from crypt import crypt

osp = sys.path
sys.path = ["../../code", "../../www/ead"]
sys.path.extend(osp)

# quick check if they asked for options
if ('-h' in sys.argv) or ('--help' in sys.argv) or ('--options' in sys.argv):
    print '\n'.join([
        '-adduser'.ljust(20) + 'add a new administrative user',
        '-load'.ljust(20) + 'load and index full records',
        '-index'.ljust(20) + 'index all records already loaded',
        '-load_components'.ljust(20) + 'extract components, load and index them',
        '-index_components'.ljust(20) + 'index all components already loaded',
        '-cluster'.ljust(20) + 'complete cluster indexing (used by subject finder)',
        '-cache'.ljust(20) + 'build HTML copies of larger records'
        ])
    sys.exit()

from baseObjects import Session
from server import SimpleServer
from document import StringDocument
from PyZ3950 import CQLParser
import c3errors

from www_utils import *
# import customisable variables
from localConfig import *

# Build environment...
session = Session()
serv = SimpleServer(session, "../../configs/serverConfig.xml")
session.database = 'db_ead'

db = serv.get_object(session, 'db_ead')
clusDb = serv.get_object(session, 'db_ead_cluster')
recordStore = db.get_object(session, 'recordStore')
compStore = db.get_object(session, 'componentStore')
clusRecordStore = clusDb.get_object(session, 'eadClusterStore')

#compDocFac = db.get_object(session, 'componentDocumentFactory')

sax = db.get_object(session, 'SaxParser')
authStore = db.get_object(session, 'eadAuthStore')


def inputError(msg):
    print 'ERROR: ' + msg
    sys.exit()


if ('-adduser' in sys.argv):
    un = raw_input('Please enter a username: ')
    if not un: inputError('You must enter a username for this user.')
    pw = getpass.getpass('Please enter a password for this user: ')
    if not (pw and len(pw)): inputError('You must enter a password for this user.')
    pw2 = getpass.getpass('Please re-enter the password to confirm: ')
    if pw != pw2: inputError('The two passwords submitted did not match. Please try again.')
    rn = raw_input('Real name of this user (not mandatory): ')
    addy = raw_input('Email address for this user (not mandatory): ')
    xml = read_file('admin.xml').replace('%USERNAME%', un)
    for k,v in {'%password%': crypt(pw, pw[:2]), '%realName%': rn, '%email%': addy}.iteritems():
        if v and len(v):
            xml = xml.replace(k, '\n  <%s>%s</%s>' % (k[1:-1],v,k[1:-1]))
        else:
            xml = xml.replace(k, '')
    doc = StringDocument(xml)
    rec = sax.process_document(session, doc)
    id = rec.process_xpath('/config/@id')[0]
    rec.id = id
    authStore.store_record(session, rec)
    authStore.commit_storing(session)
    try:
        user = authStore.fetch_object(session, id)
    except c3errors.FileDoesNotExistException:
        print 'ERROR: User not successfully created. Please try again.'
    else:
        print 'OK: Username and passwords set for this user'
    #print user
    sys.exit()


if ('-load' in sys.argv):
    start = time.time()
    # build necessary objects
    flow = db.get_object(session, 'buildIndexWorkflow')
    baseDocFac = db.get_object(session, 'baseDocumentFactory')
    baseDocFac.load(session)
    print 'Loading from %s...' % (baseDocFac.dataPath)
    flow.load_cache(session, db)
    flow.process(session, baseDocFac)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    print 'Indexing complete (%dh %dm %ds)' % (hours, mins, secs)
    

if ('-index' in sys.argv):
    start = time.time()
    db.begin_indexing(session)
    print "Indexing records..."
    for rec in recordStore:
        print rec.id.ljust(40),
        try:
            db.index_record(session, rec)
            print '[OK]'
        except UnicodeDecodeError:
            print '[Some indexes not built - non unicode characters!]'
        del rec
            
    db.commit_indexing(session)
    db.commit_metadata(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    print 'Indexing complete (%dh %dm %ds)' % (hours, mins, secs)


if ('-cluster' in sys.argv):
    start = time.time()
    # set session.database to the cluster DB
    session.database = 'db_ead_cluster'
    # build necessary objects
    clusFlow = clusDb.get_object(session, 'buildClusterWorkflow')
    clusDocFac = db.get_object(session, 'clusterDocumentFactory')
    try:
        clusDocFac.load(session, clusDocFac.get_default(session, 'data'))
    except c3errors.FileDoesNotExistException:
        # return session.database to the default (finding aid) DB
        print '*** No cluster data present.'
    else:
        print 'Clustering subjects...'
        try:
            clusFlow.process(session, clusDocFac)
        except:
            raise
    
    # return session.database to the default (finding aid) DB
    session.database = 'db_ead'
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    print 'Cluster Indexing complete (%dh %dm %ds)' % (hours, mins, secs)


if ('-load_components' in sys.argv):
    start = time.time()
    compFlow = db.get_object(session, 'buildAllComponentWorkflow')
    compFlow.load_cache(session, db)
    compFlow.process(session, recordStore)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    print 'Component Indexing complete (%dh %dm %ds)' % (hours, mins, secs)
    
    
if ('-index_components' in sys.argv):
    start = time.time()
    db.begin_indexing(session)
    print "Indexing components..."
    parent = ''
    for rec in compStore:
        print rec.id.ljust(40),
        try:
            db.index_record(session, rec)
            print '[OK]'
        except UnicodeDecodeError:
            print '[Some indexes not built - non unicode characters!]'
        del rec
            
    db.commit_indexing(session)
    db.commit_metadata(session)
    (mins, secs) = divmod(time.time() - start, 60)
    (hours, mins) = divmod(mins, 60)
    print 'Component Indexing complete (%dh %dm %ds)' % (hours, mins, secs)

script = '/ead/search/eadSearchHandler'
        
def cache_html():
    fullTxr = db.get_object(session, 'htmlFullTxr')
    fullSplitTxr = db.get_object(session, 'htmlFullSplitTxr')
    idList = recordStore.fetch_idList(session)
    total = len(idList)
    print "Caching HTML for %d records..." % (total)
    for rec in recordStore:
        recid = rec.id
        print rec.id.ljust(50),
        # FIXME: rec.size is always 0
        # small record assumed to be < 100kb ...
#        if (rec.size * 6 < (100 * 1024)):
#            print '[Build at access time - record is really small (approx %d kb)]' % (rec.size*6)
#            continue
        paramDict = {
                'RECID': recid,
                'TOC_CACHE_URL': toc_cache_url,
                '%REP_NAME%':repository_name, 
                '%REP_LINK%':repository_link,
                '%REP_LOGO%':repository_logo, 
                '%TITLE%': 'Display in Full',
                '%NAVBAR%': '',
                'SCRIPT':script
        }
    
        path = '%s/%s-1.shtml' % (cache_path, recid)
        rec = recordStore.fetch_record(session, recid)
        
        tmpl = read_file(templatePath)
        anchorPageHash = {}
        if (len(rec.get_xml()) < maximum_page_size * 1024):
            # Oh good. Nice and short record - do it the easy way
            doc = fullTxr.process_record(session, rec)
            # open, read, delete tocfile NOW to avoid overwriting screwups
            try:
                tocfile = read_file(os.path.join(toc_cache_path, 'foo.bar'))
                os.remove(os.path.join(toc_cache_path, 'foo.bar'))
                tocfile = tocfile.replace('RECID', recid)
            except:
                pass
                    
            doc = doc.get_raw()
            try: doc = doc.encode('utf-8', 'latin-1')
            except: pass # hope for the best!
            page = tmpl.replace('%CONTENT%', doc)
            for k, v in paramDict.iteritems():
                page = page.replace(k, v)
                
            write_file(path, page)
            print '\t[OK]'
        else:
            # Long record - have to do splitting, link resolving etc.
            doc = fullSplitTxr.process_record(session, rec)
            # open, read, and delete tocfile NOW to avoid overwriting screwups
            try:
                tocfile = read_file(os.path.join(toc_cache_path, 'foo.bar'))
                os.remove(os.path.join(toc_cache_path, 'foo.bar'))
                tocfile = tocfile.replace('RECID', recid)
            except:
                pass
                    
            doc = doc.get_raw()
            try: doc = doc.encode('utf-8', 'latin-1')
            except: pass # hope for the best!
            # before we split need to find all internal anchors
            anchor_re = re.compile('<a .*?name="(.*?)".*?>')
            anchors = anchor_re.findall(doc)
            pseudopages = doc.split('<p style="page-break-before: always"/>')
            pages = []
            while pseudopages:
                page = '<div id="padder"><div id="rightcol" class="ead"><div class="pagenav">%PAGENAV%</div>'
                while (len(page) < maximum_page_size * 1024):
                    page = page + pseudopages.pop(0)
                    if not pseudopages:
                        break
                        
                # append: pagenav, end rightcol div, end padder div, left div (containing toc)
                page = page + '<div class="pagenav">%PAGENAV%</div>\n</div>\n</div>\n<div id="leftcol" class="toc"><!--#include virtual="/ead/tocs/RECID.inc"--></div>'
                pages.append(page)
                
            start = 0
            for a in anchors:
                for x in range(start, len(pages)):
                    if (pages[x].find('name="%s"' % a) > -1):
                        anchorPageHash[a] = x + 1
                        start = x                                       # next anchor must be on this page or later
                        
            for x in range(len(pages)):
                doc = pages[x]
                # now we know how many real pages there are, generate some page navigation links
                pagenav = ['<div class="backlinks">']
                if (x > 0):
                    pagenav.extend(['<a href="%s/%s-1.shtml" title="First page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/fback.gif" alt="First"/></a>' % (cache_url, recid, recid),
                                    '<a href="%s/%s-%d.shtml" title="Previous page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/back.gif" alt="Previous"/></a>' % (cache_url, recid, x, recid)])
                pagenav.extend(['</div>', '<div class="forwardlinks">'])
                if (x < len(pages)-1):
                    pagenav.extend(['<a href="%s/%s-%d.shtml" title="Next page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/forward.gif" alt="Next"/></a>' % (cache_url, recid, x+2, recid),
                                    '<a href="%s/%s-%d.shtml" title="Final page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/fforward.gif" alt="Final"/></a>' % (cache_url, recid, len(pages), recid)
                                  ])
                pagenav.append('</div><div class="numnav">')
                for y in range(len(pages)):
                    if (y == x):
                        pagenav.append('<strong>%d</strong>' % (y+1))
                    else:
                        pagenav.append('<a href="%s/%s-%d.shtml" title="Page %d" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%d</a>' % (cache_url, recid, y+1, y+1, recid, y+1))
                pagenav.append('</div>')

                # now stick the page together and send it back
                pagex = tmpl.replace('%CONTENT%', doc)
                pagex = pagex.replace('%PAGENAV%', '\n'.join(pagenav))

                #resolve internal ref links
                for k, v in anchorPageHash.iteritems():
                    pagex = pagex.replace('PAGE#%s"' % k, '%s/RECID-%d.shtml#%s"' % (cache_url, v, k))

                # any remaining links were not anchored - encoders fault :( - hope they're on page 1
                pagex = pagex.replace('PAGE#', '%s/RECID-1.shtml#' % cache_url)
                        
                for k, v in paramDict.iteritems():
                    pagex = pagex.replace(k, v)
                            
                write_file('%s/%s-%d.shtml' % (cache_path, recid, x+1), pagex)
            print '\t[OK - %d pages]' % len(pages)
            
        try:
            if anchorPageHash:
                for k, v in anchorPageHash.iteritems():
                    tocfile = tocfile.replace('PAGE#%s"' % k, '%s/%s-%d.shtml#%s"' % (cache_url, recid, v, k))

                # any remaining links were not anchored - encoders fault :( - hope they're on page 1
                tocfile = tocfile.replace('PAGE#', '%s/%s-1.shtml#' % (cache_url, recid))
            else:
                # must all be on 1 page
                tocfile = tocfile.replace('PAGE#', '%s/%s-1.shtml#' % (cache_url, recid))

            write_file(os.path.join(toc_cache_path, recid +'.inc'), tocfile)
            os.chmod(os.path.join(toc_cach_path, recid + '.inc'), 0755)
                    
        except:
            pass


if ('-cache_html' in sys.argv):
    cache_html()
            
#- end -cache

