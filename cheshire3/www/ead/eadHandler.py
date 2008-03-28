#
# Script:    eadHandler.py
# Version:   0.06
# Date:      12 January 2008
# Copyright: &copy; University of Liverpool 2005-2008
# Description:
#            Globals and parent class web interfaces to a Cheshire3 database of EAD finding aids.
#            - part of Cheshire for Archives v3
#
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
#            CS - Catherine Smith <catherine.smith@liv.ac.uk>
#
# Language:  Python
#
# Version History:
# 0.01 - 12/10/2007 - JH - Globals migrated from separate files, parent class created
# 0.02 - 06/11/2007 - JH - Migrated to new architecture: extractor --> tokenizer -- tokenMerge
# 0.03 - 26/11/2007 - JH - More API changes: 
#                        -    spelling corrections for extracter, normaliser etc.
#                        -    session arg added to get_raw|xml|dom|sax functions
#                        -    fetch_idList removed - all stores iterable
# 0.04 - 14/12/2007 - JH - Non-ascii character handling fixes
# 0.05 - 03/01/2008 - CS - _parse_upload function moved here from adminHandler as also used in editing handler
# 0.06 - 12/02/2008 - CS - _walk_directory function moved here from adminHandler as also used in editing handler
# 

# import mod_python stuffs
from mod_python import apache, Cookie
from mod_python.util import FieldStorage, redirect
# import generally useful modules
import sys, traceback, os, cgitb, urllib, time, smtplib, re
from crypt import crypt
from threading import Thread
from email import Message, MIMEMultipart, MIMEText # email modules
from lxml import etree # Lxml tree manipulation
# import customisable variables
from localConfig import *
# set sys paths 
osp = sys.path
sys.path = [os.path.join(cheshirePath, 'cheshire3', 'code')]
sys.path.extend(osp)
# import Cheshire3/PyZ3950 stuff
from baseObjects import Session, Record
from server import SimpleServer
from PyZ3950 import CQLParser, SRWDiagnostics
from document import StringDocument
from record import LxmlRecord, SaxRecord, FtDomRecord
from utils import flattenTexts
import c3errors
# C3 web search utils
from www_utils import *

# regexs
# Deprecated in favour of ProximityIndex offsets
#punctuationRe = re.compile('([@+=;!?:*"{}()\[\]\~/\\|\#\&\^]|[-.,\'](?=\s+)|(?<=\s)[-.,\'])')   # this busts when there are accented chars(?)
wordRe = re.compile('\s*\S+')
emailRe = re.compile('^[a-zA-Z][^@ .]*(\.[^@ .]+)*@[^@ .]+\.[^@ .]+(\.[^@ .]+)*$')    # e.g. foo@bar.com
anchorRe = re.compile('<a .*?name="(.*?)".*?>')

overescapedAmpRe = re.compile('&amp;([^\s]*?);')
def unescapeCharent(mo):
    return '&%s;' % mo.group(1)

nonAsciiRe = re.compile('([\x7b-\xff])')
def asciiFriendly(mo):
    return "&#%s;" % ord(mo.group(1))

firstlog_re = re.compile('^\[(\d\d\d\d\-\d\d\-\d\d \d\d:\d\d:\d\d)\]', re.MULTILINE) #first date and time stamp in file
loginstance_re = re.compile('^\[.+?secs$', re.MULTILINE|re.DOTALL)
timeTaken_re = re.compile('^\.\.\.Total time: (\d+\.\d+) secs$', re.MULTILINE)
emailRe = re.compile('[^@\s]+(\.[^@\s])*@[^@\s]+\.[^@\s]+(\.[^@\s])*')
overescapedAmpRe = re.compile('&amp;([^\s]*?);')
recid_re = {}
recid_re['full'] = re.compile(': Full-text requested.+: (.+)$', re.MULTILINE)
recid_re['summary'] = re.compile(': Summary requested.+: (.+)$', re.MULTILINE)
recid_re['email'] = re.compile(': Record (.+?) emailed to (.+)$', re.MULTILINE)



class EadHandler:
    # Hierarchical class - must be subclassed to actually interact with database
    logger = None
    htmlTitle = []
    htmlNav = []
    templatePath = None
    globalReplacements = {}
    txrHash = {}
    
    def __init__(self, lgr):
        global rebuild
        if (rebuild):
            build_architecture()
        self.logger = lgr
        self.htmlTitle = []
        self.htmlNav = []
        self.templatePath = os.path.join(htmlPath, 'template.ssi')
        self.globalReplacements = {'%REP_NAME%': repository_name,
                              '%REP_LINK%': repository_link,
                              '%REP_LOGO%': repository_logo,
                              'SCRIPT': script,
                              '%SCRIPT%': script
                              }

        #- end __init__() ----------------------------------------------------------
        
    def send_html(self, data, req, code=200):
        req.content_type = 'text/html'
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
          data = data.encode('utf-8')
        req.write(data)
        req.flush()
        
        #- end send_html() ---------------------------------------------------------
    
    
    
    def _stripOffendingChar(self, exception):
        text = exception.object
        return text[:exception.start] + '<span class="error" title="This character could not be encoded for display">*</span>' + text[exception.end:]
    
    
    def _parse_upload(self, data):
        if (type(data) == unicode):
            try: data = data.encode('utf-8')
            except:
                try: data = data.encode('utf-16')
                except: pass # hope for the best!
        doc = StringDocument(data)
        doc = ppFlow.process(session, doc)
        try:
            rec = docParser.process_document(session, doc)
        except:
            newlineRe = re.compile('(\s\s+)')
            doc.text = newlineRe.sub('\n\g<1>', doc.get_raw(session))
            # repeat parse with correct line numbers
            try:
                rec = docParser.process_document(session, doc)
            except:
                self.htmlTitle.append('Error')
                e = sys.exc_info()
                self.logger.log('*** %s: %s' % (e[0], e[1]))
                # try and highlight error in specified place
                lines = doc.get_raw(session).split('\n')
                positionRe = re.compile(':(\d+):(\d+):')
                mo = positionRe.search(str(e[1]))
                line, posn = lines[int(mo.group(1))-1], int(mo.group(2))
                startspace = newlineRe.match(line).group(0)
                return '''\
        <div id="wrapper"><p class="error">An error occured while parsing your file. 
        Please check the file at the suggested location and try again.</p>
        <code>%s: %s</code>
        <pre>
        %s
        <span class="error">%s</span>
        </pre>
        <p><a href="files.html">Back to file page</a></p></div>
                ''' % (e[0], e[1], html_encode(line[:posn+20]) + '...',  startspace + str('-'*(posn-len(startspace))) +'^')
        
        del data, doc
        return rec
    # end _parse_upload()

    def view_file(self, form):
        global script
        self.htmlTitle.append('File Management')

        self.htmlNav.append('<a href="files.html" title="File Management" class="navlink">Files</a>')
        filepath = form.get('filepath', None)
        if not filepath:
            self.htmlTitle.append('Error')
            return 'Could not locate specified file path'

        self.htmlTitle.append('View File')

        out = ['<div class="heading">%s</div>' % (filepath),'<pre>']
        out.append(html_encode(read_file(filepath)))
        out.append('</pre>')

        return '\n'.join(out)
    #- end view_file()




    def _walk_directory(self, d, type='checkbox'):
        global script
        # we want to keep all dirs at the top, followed by all files
        outD = []
        outF = []
        filelist = os.listdir(d)
        filelist.sort()
        for f in filelist:
            if (os.path.isdir(os.path.join(d,f))):
                outD.extend(['<li title="%s">%s' % (os.path.join(d,f),f),
                            '<ul class="hierarchy">',
                            '\n'.join(self._walk_directory(os.path.join(d, f), type)),
                            '</ul></li>'
                            ])
            else:
                fp = os.path.join(d,f)
                outF.extend(['<li>'
                            ,'<span class="fileops"><input type="%s" name="filepath" value="%s"/></span>' % (type, fp)
                            ,'<span class="filename"><a href="files.html?operation=view&amp;filepath=%s" title="View file contents">%s</a></span>' % (cgi_encode(fp), f)
                            ,'</li>'
                            ])

        return outD + outF
        
        #- end walk_directory()
    

    
    def display_full(self, rec, paramDict):
        recid = rec.id
        try: l = rec.byteCount
        except: l = len(rec.get_xml(session))
        if (l < max_page_size_bytes):
            # Nice and short record/component - do it the easy way
            self.logger.log('HTML generated by non-splitting XSLT')
            doc = fullTxr.process_record(session, rec)
        else:
            doc = fullSplitTxr.process_record(session, rec)
            # Long record - have to do splitting, link resolving etc.
            self.logger.log('HTML generated by splitting XSLT')

        # open, read, and delete tocfile NOW to avoid overwriting screwups
        try:
            tocfile = unicode(read_file(os.path.join(toc_cache_path, 'foo.bar')), 'utf-8')
        except IOError:
            tocfile = None
        else:
            os.remove(os.path.join(toc_cache_path, 'foo.bar'))
            tocfile = nonAsciiRe.sub(asciiFriendly, tocfile)
            tocfile = tocfile.replace('RECID', recid)
            #tocfile = overescapedAmpRe.sub(unescapeCharent, tocfile)
        
        doc = unicode(doc.get_raw(session), 'utf-8')
        doc = nonAsciiRe.sub(asciiFriendly, doc)
        #doc = overescapedAmpRe.sub(unescapeCharent, doc)
        tmpl = read_file(self.templatePath)
        if (l < max_page_size_bytes):
            # resolve anchors to only page
            #doc = nonAsciiRe.sub(asciiFriendly, doc)
            doc = doc.replace('PAGE#', '%s/RECID-p1.shtml#' % cache_url)
            doc = doc.replace('LINKTOPARENT', paramDict['LINKTOPARENT'])
            page = tmpl.replace('%CONTENT%', toc_scripts + doc)
            self.logger.log(repr(paramDict))
            pages = [multiReplace(page, paramDict)]
            write_file(os.path.join(cache_path, recid + '-p1.shtml'), pages[0])
        else:
            # before we split need to find all internal anchors
            anchors = anchorRe.findall(doc)
            pseudopages = doc.split('<p style="page-break-before: always"/>')
            if len(pseudopages) == 1:
                pseudopages = doc.split('<p style="page-break-before: always"></p>')
                
            pages = []
            while pseudopages:
                pagebits = ['<div id="padder"><div id="rightcol" class="ead">', '%PAGENAV%']
                while (sum(map(len, pagebits)) < max_page_size_bytes):
                    pagebits.append(pseudopages.pop(0))
                    if not pseudopages:
                        break
                
                # append: pagenav, end rightcol div, padder div, left div (containing toc)
                pagebits.extend(['%PAGENAV%','<br/>','</div><!-- end rightcol -->','</div><!-- end padder -->','<div id="leftcol" class="toc"><!--#config errmsg="[ Table of Contents unavailable ]" --><!--#include virtual="/ead/tocs/RECID.inc"--></div>'])
                pages.append('\n'.join(pagebits))

            start = 0
            anchorPageHash = {}
            for a in anchors:
                if len(a.strip()) > 0:
                    for x in range(start, len(pages), 1):
                        if (pages[x].find('name="%s"' % a) > -1):
                            anchorPageHash[a] = x + 1
                            start = x                                  # next anchor must be on this page or later

            self.logger.log('Links resolved over multiple pages (%d pages)' % (len(pages)))

            for x in range(len(pages)):
                doc = pages[x]
                # now we know how many real pages there are, generate some page navigation links
                if len(pages) > 1:
                    pagenav = ['<div class="pagenav">', '<div class="backlinks">']
                    if (x > 0):
                        pagenav.extend(['<a href="%s/%s-p1.shtml" title="First page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/fback.gif" alt="First"/></a>' % (cache_url, recid, recid), 
                                        '<a href="%s/%s-p%d.shtml" title="Previous page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/back.gif" alt="Previous"/></a>' % (cache_url, recid, x, recid)
                                      ])
                    pagenav.extend(['</div>', '<div class="forwardlinks">'])
                    if (x < len(pages)-1):
                        pagenav.extend(['<a href="%s/%s-p%d.shtml" title="Next page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/forward.gif" alt="Next"/></a>' % (cache_url, recid, x+2, recid),
                                        '<a href="%s/%s-p%d.shtml" title="Final page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))"><img src="/images/fforward.gif" alt="Final"/></a>' % (cache_url, recid, len(pages), recid)
                                      ])
                    pagenav.extend(['</div>', '<div class="numnav">'])
                    # individual number links
#                    for y in range(len(pages)):
#                        if (y == x):
#                            pagenav.append('<strong>%d</strong>' % (y+1))
#                        else:
#                            pagenav.append('<a href="%s/%s-p%d.shtml" title="Page %d" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%d</a>' % (cache_url, recid, y+1, y+1, recid, y+1))
                    # form style - Page: x of X
                    pagenav.extend(['<form action="%s">Page: ' % (script)
                                   ,'<input type="hidden" name="operation" value="full" />'
                                   ,'<input type="hidden" name="recid" value="%s" />' % (recid)
                                   ,'<input type="text" name="page" size="2" maxlength="3" value="%d"/> of %d' % (x+1, len(pages))
                                   ,'<input type="submit" value="Go!"/>'
                                   ,'</form>' 
                                   ])
                    # end case
                    pagenav.extend(['</div> <!--end numnav div -->', '</div> <!-- end pagenav div -->'])
                else:
                    pagenav = []
                
                #doc = nonAsciiRe.sub(asciiFriendly, doc)
                pagex = tmpl.replace('%CONTENT%', toc_scripts + doc)
                pagex = pagex.replace('%PAGENAV%', '\n'.join(pagenav))

                #resolve internal ref links
                for k, v in anchorPageHash.iteritems():
                    pagex = pagex.replace('PAGE#%s"' % k, '%s/RECID-p%d.shtml#%s"' % (cache_url, v, k))

                # any remaining links were not anchored - encoders fault :( - hope they're on page 1
                pagex = pagex.replace('PAGE#', '%s/RECID-p1.shtml#' % (cache_url))
                pagex = multiReplace(pagex, paramDict)
                pages[x] = pagex
                pagex = pagex.encode('utf-8')
                write_file(os.path.join(cache_path, recid + '-p%d.shtml' % (x+1)), pagex)

            self.logger.log('Multi-page navigation generated')
 
        del rec
        if tocfile:
            try:
                for k, v in anchorPageHash.iteritems():
                    tocfile = tocfile.replace('PAGE#%s"' % k, '%s/%s-p%d.shtml#%s"' % (cache_url, recid, v, k))
            except UnboundLocalError:
                pass
            
            # any remaining links were not anchored - encoders fault :( - hope they're on page 1
            tocfile = multiReplace(tocfile, {'SCRIPT': script, 'PAGE#': '%s/%s-p1.shtml#' % (cache_url, recid)})
            tocfile = tocfile.encode('utf-8')
            write_file(os.path.join(toc_cache_path, recid +'.inc'), tocfile)
            os.chmod(os.path.join(toc_cache_path, recid + '.inc'), 0755)
 
        return pages
    
        #- end display_full() -------------------------------------------------
        
    #- end EadHandler

#- Some stuff to do on initialisation
session = None
serv = None
db = None
dbPath = None
# ingest
baseDocFac = None
sourceDir = None
docParser = None
# stores
authStore = None
recordStore = None
dcStore = None
compStore = None
resultSetStore = None
# clusters
clusDb = None
clusStore = None
# transformers
summaryTxr = None
fullTxr = None
fullSplitTxr = None
textTxr = None
# workflows
ppFlow = None
buildFlow = None
buildSingleFlow = None
indexRecordFlow = None
assignDataIdFlow = None
normIdFlow = None
clusFlow = None
compFlow = None
compRecordFlow = None
# other
extractor = None
diacriticNormalizer = None

rebuild = True

def build_architecture(data=None):
    # data argument provided for when function run as clean-up - always None
    global session, serv, db, dbPath, baseDocFac, sourceDir, docParser, \
    authStore, recordStore, dcRecordStore, compStore, resultSetStore, \
    clusDb, clusStore, clusFlow, \
    summaryTxr, fullTxr, fullSplitTxr, textTxr, \
    ppFlow, buildFlow, buildSingleFlow, indexRecordFlow, assignDataIdFlow, normIdFlow, compFlow, compRecordFlow, \
    extractor, diacriticNormalizer, \
    rebuild
    
    # globals line 1: re-establish session; maintain user if possible
    if (session): u = session.user
    else: u = None
    session = Session()
    session.database = 'db_ead'
    session.environment = 'apache'
    session.user = u
    serv = SimpleServer(session, os.path.join(cheshirePath, 'cheshire3', 'configs', 'serverConfig.xml'))
    db = serv.get_object(session, 'db_ead')
    dbPath = db.get_path(session, 'defaultPath')
    baseDocFac = db.get_object(session, 'baseDocumentFactory')
    sourceDir = baseDocFac.get_default(session, 'data')
    docParser = db.get_object(session, 'LxmlParser')
    # globals line 2: stores
    authStore = db.get_object(session, 'eadAuthStore')
    recordStore = db.get_object(session, 'recordStore')
    dcRecordStore = db.get_object(session, 'eadDcStore')
    compStore = db.get_object(session, 'componentStore')
    resultSetStore = db.get_object(session, 'eadResultSetStore'); resultSetStore.clean(session) # clean expires resultSets 
    # globals line 3: subject clusters
    session.database = 'db_ead_cluster'
    clusDb = serv.get_object(session, 'db_ead_cluster')
    clusStore = clusDb.get_object(session, 'eadClusterStore')
    clusFlow = clusDb.get_object(session, 'buildClusterWorkflow'); clusFlow.load_cache(session, clusDb) 
    session.database = 'db_ead'
    # globals line 4: transformers
    summaryTxr = db.get_object(session, 'htmlSummaryTxr')
    fullTxr = db.get_object(session, 'htmlFullTxr')
    fullSplitTxr = db.get_object(session, 'htmlFullSplitTxr')
    textTxr = db.get_object(session, 'textTxr')
    # globals line 5: workflows
    ppFlow = db.get_object(session, 'preParserWorkflow'); ppFlow.load_cache(session, db)
    buildFlow = db.get_object(session, 'buildIndexWorkflow'); buildFlow.load_cache(session, db)
    buildSingleFlow = db.get_object(session, 'buildIndexSingleWorkflow'); buildSingleFlow.load_cache(session, db)
    indexRecordFlow = db.get_object(session, 'indexRecordWorkflow'); indexRecordFlow.load_cache(session, db)
    assignDataIdFlow = db.get_object(session, 'assignDataIdentifierWorkflow'); assignDataIdFlow.load_cache(session, db)
    normIdFlow = db.get_object(session, 'normalizeDataIdentifierWorkflow'); normIdFlow.load_cache(session, db)
    compFlow = db.get_object(session, 'buildAllComponentWorkflow'); compFlow.load_cache(session, db)
    compRecordFlow = db.get_object(session, 'buildComponentWorkflow'); compRecordFlow.load_cache(session, db)
    # globals line 6: other
    extractor = db.get_object(session, 'SimpleExtractor')
    diacriticNormalizer = db.get_object(session, 'DiacriticNormalizer')
    
    rebuild = False
    