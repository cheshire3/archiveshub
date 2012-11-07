#
# Script:    eadHandler.py
# Version:   0.09
# Date:      15 December 2011
# Copyright: &copy; University of Liverpool 2005-present
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
# 0.07 - 09/01/2008 - JH - _parse_upload bug fix
# 0.08 - 22/11/2010 - JH - Provision for exception logging / reporting
# 0.09 - 15/03/2011 - JH - Bug fixe for ToC character encoding fixed - coerce to unicode when read in
#


import sys
import os
import urllib
import time
import smtplib
import re
import traceback
import cgitb

from crypt import crypt
from email import Message, MIMEMultipart, MIMEText # email modules
# Lxml tree manipulation
from lxml import etree 
from lxml.builder import E

# import mod_python stuffs
from mod_python import apache, Cookie
from mod_python.util import FieldStorage, redirect
# import generally useful modules

# import customisable variables
from localConfig import *

# set sys paths
sys.path.insert(1, os.path.join(cheshirePath, 'cheshire3', 'code'))

# Cheshire3 stuff
from cheshire3.baseObjects import Session, Record, ResultSet
from cheshire3.server import SimpleServer
from cheshire3.document import StringDocument
from cheshire3.utils import flattenTexts
from cheshire3 import exceptions as c3errors
from cheshire3.web.www_utils import *

# PyZ39.50 stuff
from PyZ3950 import SRWDiagnostics
from cheshire3.cqlParser import Diagnostic as CQLDiagnostic

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


class EadHandler(object):
    # Hierarchical class - must be subclassed to actually interact with database
    logger = None
    excLogger = None
    htmlTitle = []
    htmlNav = []
    templatePath = None
    req = None
    cookies = None
    globalReplacements = {}
    txrHash = {}
    
    def __init__(self, lgr=None, myscript=None):
        global rebuild
        if (rebuild):
            build_architecture()
            
        self.logger = lgr
        try:
            self.excLogger = db.get_object(session, 'webExceptionLogger')
        except:
            pass
        if myscript is not None:
            self.script = myscript
        else:
            self.script = script
        self.htmlTitle = []
        self.htmlNav = []
        self.templatePath = os.path.join(htmlPath, 'template.ssi')
        self.globalReplacements = {'%REP_NAME%': repository_name
                                  ,'%REP_LINK%': repository_link
                                  ,'%REP_LOGO%': repository_logo
                                  ,'SCRIPT': self.script
                                  ,'%SCRIPT%': self.script
                                  ,'<br>': '<br/>'
                                  ,'<hr>': '<hr/>'
                              }
        #- end __init__() ----------------------------------------------------------
        
    def log(self, txt):
        try:
            self.logger.log(txt)
        except AttributeError:
            pass
        
    def logExc(self, txt):
        try:
            self.excLogger.log_error(session, txt)
        except AttributeError:
            pass
        
    def send_data(self, data, req, code=200, content_type='text/html'):
        req.content_type = content_type
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
          data = data.encode('utf-8')
        req.write(data)
        del data
        req.flush()
        
    def send_html(self, data, req, code=200):
        self.send_data(data, req, code, 'text/html')
        #- end send_html() ---------------------------------------------------
        
    def send_xml(self, data, req, code=200):
        self.send_data(data, req, code, 'application/xml')
        #- end send_xml() ----------------------------------------------------
    
    def _handle_error(self):
        self.htmlTitle.append('Error')
        cla, exc, trbk = sys.exc_info()
        excName = cla.__name__
        try:
            excArgs = exc.__dict__["args"]
        except KeyError:
            excArgs = str(exc)
        excTb = traceback.format_tb(trbk, 100)
        self.log('*** {0}: {1}'.format(excName, excArgs))
        self.logExc('{0}: {1}\n{2}'.format(excName, excArgs, '\n'.join(excTb)))
        excName = html_encode(excName)
        excArgs = html_encode(excArgs)
        
        excTb = '<br/>\n'.join([html_encode(line) for line in excTb])
        return '''\
        <div id="single">
          <p class="error">An error occurred while processing your request.
            <br/>The message returned was as follows:
          </p>
          <code>{0}: {1}</code>
          <p>
            <strong>
              Please try again, or contact the system administrator if this 
              problem persists.
            </strong>
          </p>
          <p>Debugging Traceback: 
            <a href="#traceback" class="jstoggle-text">[ hide ]</a>
          </p>
          <div id="traceback" class="jshide">{2}</div>
        </div> <!-- /single -->
        '''.format(excName, excArgs, excTb)
        #- / _handle_error() ------------------------------------------------
    
    def _get_genericHtml(self, fn):
        global repository_name, repository_link, repository_logo
        html = read_file(fn)
        paramDict = self.globalReplacements
        paramDict.update({'%TITLE%': title_separator.join(self.htmlTitle)
                         ,'%NAVBAR%': navbar_separator.join(self.htmlNav)
                         })
        return multiReplace(html, paramDict)
        #- end _get_genericHtml()
        
    def _get_timeStamp(self):
        return time.strftime('%Y-%m-%dT%H%M%S')
    
    def _stripOffendingChar(self, exception):
        text = exception.object
        return text[:exception.start] + '<span class="error" title="This character could not be encoded for display">*</span>' + text[exception.end:]
    
    def _parse_upload(self, data, interface='admin'):
        if (type(data) == unicode):
            try: data = data.encode('utf-8')
            except:
                try: data = data.encode('utf-16')
                except: pass # hope for the best!
        doc = StringDocument(data)
        del data
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
                self.logger.log('*** %s: %s' % (repr(e[0]), e[1]))
                # try and highlight error in specified place
                lines = doc.get_raw(session).split('\n')
                positionRe = re.compile(':(\d+):(\d+):')
                mo = positionRe.search(str(e[1]))
                if (mo is None):
                    positionRe = re.compile('line (\d+), column (\d+)')
                    mo = positionRe.search(str(e[1]))
                line, posn = lines[int(mo.group(1))-1], int(mo.group(2))
                try:
                    startspace = newlineRe.match(line).group(0)
                except:
                    if interface=='admin':
                        link = '<a href="files.html">Back to file page</a>'
                    else :
                        link = '<a href="edit.html">Back to edit/create menu</a>'
                    return '''<div id="single"><p class="error">An error occured while parsing your file. 
        Please check the file is a valid ead file and try again.</p><p>%s</p></div>''' % link
                else:
                    if interface=='admin':
                        link = '<a href="files.html">Back to file page</a>'
                    else :
                        link = '<a href="edit.html">Back to edit/create menu</a>'
                    return '''\
            <div id="single"><p class="error">An error occured while parsing your file. 
            Please check the file at the suggested location and try again.</p>
            <code>%s: %s</code>
            <pre>
            %s
            <span class="error">%s</span>
            </pre>
            <p>%s</p></div>
                    ''' % (html_encode(repr(e[0])), e[1], html_encode(line[:posn+20]) + '...',  startspace + str('-'*(posn-len(startspace))) +'^', link)
                    
        del doc
        return rec
    # end _parse_upload()

    def view_file(self, form):
        self.htmlTitle.append('File Management')

        self.htmlNav.append('<a href="files.html" title="File Management" class="navlink">Files</a>')
        filepath = form.get('filepath', None)
        if not filepath:
            self.htmlTitle.append('Error')
            return 'Could not locate specified file path'

        self.htmlTitle.append('View File')
        out = ['<div id="single">'
              ,'<div class="heading">%s</div>' % (filepath)
              ,'<pre>']
        out.append(html_encode(read_file(filepath)))
        out.append('</pre></div><!-- end single div -->')

        return '\n'.join(out)
    #- end view_file()

    def _walk_directory(self, d, type='checkbox', link=True):
        # we want to keep all dirs at the top, followed by all files
        outD = []
        outF = []
        filelist = os.listdir(d)
        filelist.sort()
        for f in filelist:
            if (os.path.isdir(os.path.join(d,f))):
                outD.extend(['<li title="%s">%s' % (os.path.join(d,f),f),
                            '<ul class="hierarchy">',
                            '\n'.join(self._walk_directory(os.path.join(d, f), type, link)),
                            '</ul></li>'
                            ])
            else:
                fp = os.path.join(d,f)
                if link:
                    outF.extend(['<li>'
                                ,'<span class="fileops"><input type="%s" name="filepath" value="%s"/></span>' % (type, fp)
                                ,'<span class="filename"><a href="files.html?operation=view&amp;filepath=%s" title="View file contents">%s</a></span>' % (cgi_encode(fp), f)
                                ,'</li>'
                                ])
                else:
                     outF.extend(['<li>'
                                ,'<span class="fileops"><input type="%s" name="filepath" value="%s"/></span>' % (type, fp)
                                ,'<span class="filename">%s</span>' % (f)
                                ,'</li>'
                                ])                   

        return outD + outF
        #- end walk_directory()
    
    def display_full(self, rec, paramDict, pageNavType='form'):
        recid = rec.id
        try:
            l = rec.byteCount
        except:
            l = len(rec.get_xml(session))
        if (l < max_page_size_bytes):
            # Nice and short record/component - do it the easy way
            self.logger.log('HTML generated by non-splitting XSLT')
            doc = fullTxr.process_record(session, rec)
        else:
            doc = fullSplitTxr.process_record(session, rec)
            # Long record - have to do splitting, link resolving etc.
            self.logger.log('HTML generated by splitting XSLT')
            
        del rec
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
            pages = [multiReplace(page, paramDict)]
            write_file(os.path.join(cache_path, recid + '-p1.shtml'), pages[0].encode('utf-8'))
        else:
            # before we split need to find all internal anchors
            anchors = anchorRe.findall(doc)
            pseudopages = doc.split('<p style="page-break-before: always"/>')
            if len(pseudopages) == 1:
                pseudopages = doc.split('<p style="page-break-before: always"></p>')
                
            pages = []
            while pseudopages:
                pagebits = ['<div id="leftcol" class="toc"><!--#config errmsg="[ Table of Contents unavailable ]" --><!--#include virtual="/ead/tocs/RECID.inc"--></div>'
                           ,'<div id="padder"><div id="rightcol" class="ead">'
                           , '%PAGENAV%']
                while (sum(map(len, pagebits)) < max_page_size_bytes):
                    pagebits.append(pseudopages.pop(0))
                    if not pseudopages:
                        break
                
                # append: pagenav, end rightcol div, padder div, left div (containing toc)
                pagebits.extend(['%PAGENAV%','<br/>'
                                ,'</div><!-- end rightcol -->'
                                ,'</div><!-- end padder -->'
                                ])
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
                pagenav = []
                if len(pages) > 1:
                    pagenav.extend(['<div class="pagenav">', '<div class="backlinks">'])
                    if (x > 0):
                        pagenav.extend(['<a href="%s/%s-p1.shtml" title="First page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%s</a>' % (cache_url, recid, recid, fback_tag), 
                                        '<a href="%s/%s-p%d.shtml" title="Previous page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%s</a>' % (cache_url, recid, x, recid, back_tag)
                                      ])
                    pagenav.extend(['</div>', '<div class="forwardlinks">'])
                    if (x < len(pages)-1):
                        pagenav.extend(['<a href="%s/%s-p%d.shtml" title="Next page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%s</a>' % (cache_url, recid, x+2, recid, forward_tag),
                                        '<a href="%s/%s-p%d.shtml" title="Final page" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%s</a>' % (cache_url, recid, len(pages), recid, fforward_tag)
                                      ])
                    pagenav.extend(['</div>', '<div class="numnav">'])
                    if pageNavType == 'form':
                        # form style - Page: x of X
                        pagenav.extend(['<form action="%s">Page: ' % (self.script)
                                       ,'<input type="hidden" name="operation" value="full" />'
                                       ,'<input type="hidden" name="recid" value="%s" />' % (recid)
                                       ,'<input type="text" name="page" size="2" maxlength="3" value="%d"/> of %d' % (x+1, len(pages))
                                       ,'<input type="submit" value="Go!"/>'
                                       ,'</form>' 
                                       ])
                    elif pageNavType == 'links':
                        # individual number links
                        for y in range(len(pages)):
                            if (y == x):
                                pagenav.append('<strong>%d</strong>' % (y+1))
                            else:
                                pagenav.append('<a href="%s/%s-p%d.shtml" title="Page %d" onclick="setCookie(\'%s-tocstate\', stateToString(\'someId\'))">%d</a>' % (cache_url, recid, y+1, y+1, recid, y+1))
                        
                    pagenav.extend(['</div> <!--end numnav div -->', '</div> <!-- end pagenav div -->'])
                
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
 
        if tocfile:
            try:
                for k, v in anchorPageHash.iteritems():
                    tocfile = tocfile.replace('PAGE#%s"' % k, '%s/%s-p%d.shtml#%s"' % (cache_url, recid, v, k))
            except UnboundLocalError:
                pass
            
            # any remaining links were not anchored - encoders fault :( - hope they're on page 1
            tocfile = multiReplace(tocfile, {'SCRIPT': self.script, 'PAGE#': '%s/%s-p1.shtml#' % (cache_url, recid)})
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
docParser = None
# stores
# transformers
fullTxr = None
fullSplitTxr = None
# workflows
ppFlow = None

rebuild = True

def build_architecture(data=None):
    # data argument provided for when function run as clean-up - always None
    global session, serv, db, dbPath, docParser, \
    fullTxr, fullSplitTxr, \
    ppFlow, \
    rebuild
    
    # globals line 1: re-establish session; maintain user if possible
    if (session):
        u = session.user
    else:
        u = None
    session = Session()
    session.database = 'db_ead'
    session.environment = 'apache'
    session.user = u
    serv = SimpleServer(session, os.path.join(cheshirePath, 'cheshire3', 'configs', 'serverConfig.xml'))
    db = serv.get_object(session, 'db_ead')
    dbPath = db.get_path(session, 'defaultPath')
    docParser = db.get_object(session, 'LxmlParser')
    # globals line 4: transformers
    fullTxr = db.get_object(session, 'htmlFullTxr')
    fullSplitTxr = db.get_object(session, 'htmlFullSplitTxr')
    # globals line 5: workflows
    ppFlow = db.get_object(session, 'preParserWorkflow'); ppFlow.load_cache(session, db)
    
    rebuild = False
    