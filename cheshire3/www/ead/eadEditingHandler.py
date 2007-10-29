#
# Script:    eadEditingHandler.py
# Version:   0.1
# Date:      ongoing
# Copyright: &copy; University of Liverpool 2007
# Description:
#            Data creation and editing interface for EAD finding aids
#            - part of Cheshire for Archives v3
#
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
#            CS - Catherine Smith <catherine.smith@liv.ac.uk>
#
# Language:  Python
# Required externals:
#            cheshire3-base, cheshire3-web
#            Py: 
#            HTML: 
#            CSS: 
#            Javascript: 
#            Images: 
#
# Version History: # left as example
# 0.01 - 06/12/2005 - JH - Basic administration navigations and menus



# import mod_python stuff
from mod_python import apache
from mod_python.util import FieldStorage
# import generally useful modules
import sys, traceback, os, cgitb, urllib, time, smtplib, re, datetime
from lxml import etree
from copy import deepcopy
# import customisable variables
from localConfig import *
# set sys paths 
osp = sys.path
sys.path = [os.path.join(cheshirePath, 'cheshire3', 'code')]
sys.path.extend(osp)
# import Cheshire3/PyZ3950 stuff
from server import SimpleServer
from PyZ3950 import CQLParser, SRWDiagnostics
from baseObjects import Session
from document import StringDocument
from record import LxmlRecord
import c3errors
# C3 web search utils
from www_utils import *

tree = None

class EadEditingHandler:
    global repository_name, repository_link, repository_logo, htmlPath
    templatePath = os.path.join(htmlPath, 'template.ssi')

    htmlTitle = None
    htmlNav = None
    logger = None

    def __init__(self, lgr):
        self.htmlTitle = ['Data Creation and Editing']
        self.htmlNav = []
        self.logger = lgr

    #- end __init__
    
    
    def send_html(self, data, req, code=200):
        req.content_type = 'text/html'
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()
        
    #- end send_html()
    
    
    def build_ead(self, req):
        global tree
        self.logger.log('building ead')
        form = FieldStorage(req)
        ctype = form.get('ctype', None)
        level = form.get('location', None)
        collection = False;
        if (level == 'collectionLevel'):
            collection = True;
            tree = etree.fromstring('<ead><eadheader></eadheader><archdesc><did></did></archdesc></ead>')
        else :
            tree = etree.fromstring('<%s><did></did></%s>' % (ctype, ctype))
        list = form.list  
        testlist = []         
        for field in list :
            if field.name not in ['ctype','location','operation','newForm','nocache','recid']:              
                #do did level stuff
                if (collection):
                    node = tree.xpath('/ead/archdesc')[0]
                else :
                    node = tree.xpath('/*[not(name() = "ead")]')[0]
                self.logger.log('pre-create_path')
                targetNode = self._create_path(node, field.name)
                self.logger.log('node returned to build ead: %s' % targetNode)
              #  targetNode = node.xpath(field.name)[0]
                targetNode.text = field.value
                raise ValueError(etree.tostring(tree))
                

        

    def _create_path(self, startNode, nodePath):  
        global tree          
        self.logger.log('the node path is %s' % nodePath)
           
        if (startNode.xpath(nodePath)):
            self.logger.log('path matches')
            self.logger.log('I return %s' % startNode.xpath(nodePath)[0])
            return startNode.xpath(nodePath)[0]
        else :
            newNodePath = ''.join(nodePath[:nodePath.rfind('/')])
            
            self.logger.log('new node path is %s' % newNodePath)
            newNode = etree.Element(''.join(nodePath[nodePath.find('/')+1:]))
            self.logger.log('new node is %s' % newNode)
            return self._append_element(self._create_path(startNode, newNodePath), newNode)
            
            
    def _append_element(self, parentNode, childNode):    
        parentNode.append(childNode)
        return parentNode
        
                
    
    def build_ead_old(self, req):
        replHashWhitespace = {'\n' : '',
                               '\t' : ''
                            }
        form = FieldStorage(req)
        
        replHashComp = {
                    '%PLCHDR_REPOSITORY%' : form.get('/ead/archdesc/did/repository', ''),                 
                    '%PLCHDR_UNITID%' : '%s %s %s' % (form.get('caa-cc', ''), form.get('caa-rc', ''), form.get('caa-id', '')),
                    '%PLCHDR_UNITTITLE%' : form.get('did/unittitle', 'no title provided'),
                    '%PLCHDR_UNITDATE%' : form.get('cac', ''),
                    '%PLCHDR_NORMAL%' : form.get('can',''),
                    '%PLCHDR_EXTENT%' : form.get('cae',''),
                    '%PLCHDR_ORIGINATION%' : form.get('cba',''),
                    '%PLCHDR_BIOGHIST%' : form.get('cbb', ''),
                    '%PLCHDR_CUSTODHIST%' : form.get('cbc', ''),
                    '%PLCHDR_ACQINFO%' : form.get('cbd', ''),
                    '%PLCHDR_SCOPECONTENT%' : form.get('cca', ''),
                    '\n' : '', 
                    '\t' : ''        
                    }      
        
        componentFile = read_file('componentlevel.xml')
        componentXml = multiReplace(componentFile, replHashComp)

        
        
        if (form.get('location', None) == 'collectionLevel'):
            replHashColl = {'%PLCHDR_EADID%' : '%s %s %s' % (form.get('caa-cc', ''), form.get('caa-rc', ''), form.get('caa-id', '')),
                            '%PLCHDR_TITLEPROPER%' : form.get('did/unittitle', 'no title provided'),
                            '%PLCHDR_DATE%' : '%s' % datetime.date.today(),
                            '%PLCHDR_COMPONENT%' : '%s' % componentXml,
                            '\n' : '',
                            '\t' : ''
                            }
              
            baseFile = read_file('collectionlevel.xml')
            xml = multiReplace(baseFile, replHashColl)
            
            replHashWrapper = {'<wrapper>' : '',
                           '</wrapper>' : ''
                           }
        
            xml1 = multiReplace(xml, replHashWrapper)
            return xml1
        else :
            replHashWrapper = {'<wrapper>' : '<%s xsl:id="%s">' % (form.get('ctype', 'c'), form.get('location', 0)),
                           '</wrapper>' : '</%s>' % form.get('ctype', 'c')
                           }
            componentXml1 = multiReplace(componentXml, replHashWrapper)

            return componentXml1

        
    def populate_form(self, recid, loc, new):  
        #if its collection level give the transformer the whole record
        if (new == 'collectionLevel'):  
            retrievedDom = editStore.fetch_record(session, recid).get_dom()
            rec = LxmlRecord(retrievedDom)
        #if its a component find the component by id and just give that component to the transformer          
        else :
            retrievedXml = editStore.fetch_record(session, recid).get_xml()
            root = None
            tree = etree.XMLID(retrievedXml)
            raise ValueError(tree) #currently dictionary does not seem to have anything in it
            node = deepcopy(tree[0].xpath('//*[@id="%s"]' % new))
            raise ValueError(node)
            for e in node :
                if root == None:
                    root = e
                else :
                    root.append(e)
            doc = StringDocument(etree.tostring(root))
            rec = xmlp.process_document(session, doc)                 
        return formTxr.process_record(session, rec).get_raw() 


    
    def save_form(self, req, loc, recid):
        self.logger.log('saving form at recid = %s'% recid)
        form = FieldStorage(req)
        if (loc == 'collectionLevel' and (recid == None or recid == 'None')):
            #save the form in any free slot
            doc = StringDocument(self.build_ead(req))                
            rec = xmlp.process_document(session, doc)       
            id = str(editStore.create_record(session, rec))
            recid = id.split('/')[1]
            editStore.commit_storing(session)   
            return recid
        elif (loc == 'collectionLevel'):            
            #pull existing xml and make into a tree
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedXml = retrievedRec.get_xml()
            tree = etree.fromstring(retrievedXml)

            #cycle through the form and replace any node that need it
            list = form.list            
            for field in list :
                if (tree.xpath(field.name)): #replace it
                    targetNode = tree.xpath(field.name)[0]
                    targetNode.text = field.value
                else :  #create it                   
                    pass
            #resave the record
            #doc = StringDocument(etree.tostring(tree))
            #rec = xmlp.process_document(session, doc)
            rec = LxmlRecord(tree)
            rec.id = retrievedRec.id
            editStore.store_record(session, rec)
            editStore.commit_storing(session)
            return recid
       
        #check if C exists, if not add it, if so replace it
        else :
            #pull record from store
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedxml= retrievedRec.get_xml()
            tree = etree.fromstring(retrievedxml)            
            #first check there is a dsc element and if not add one (needed for next set of xpath tests)
            if not (tree.xpath('/ead/archdesc/dsc')):
                archdesc = tree.xpath('/ead/archdesc')[0]    
                dsc = etree.Element('dsc')     
                archdesc.append(dsc)                   
            #construct the xpath for the component
            clist = loc.split('-')
            xpathString = '/ead/archdesc/dsc'
            for i in range(1, len(clist)):
                xpathString += '/*[starts-with(name(), "c")][%s]' % clist[i]  
        
            #if the component does not exist add it
            if not (tree.xpath(xpathString)):
                #raise ValueError(xpathString)
                dsc = tree.xpath('/ead/archdesc/dsc')[0]
                #dsc.append(newTree)
                doc1 = StringDocument(etree.tostring(tree))
                rec = xmlp.process_document(session, doc1)
                rec.id = retrievedRec.id
                self.logger.log('form was a new component and the xml saved was %s ' % rec.get_xml())
                editStore.store_record(session, rec)
                editStore.commit_storing(session) 
                
            #if the component does exist change it
            else :                
                #find component in current record
                currentComp = tree.xpath(xpathString)
                #raise ValueError(currentComp)
                
                #replace the current component with the new component
                
                #re-store new record
            return recid    
            
        
    def add_form(self, req):
        form = FieldStorage(req)     
        loc = form.get('location', None)
        recid = form.get('recid', None)        
        recid = self.save_form(req, loc, recid)
        doc = StringDocument('<c><recid>%s</recid></c>' % recid)
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw()
        return htmlform


    def navigate(self, req):
        form = FieldStorage(req)
        loc = form.get('location', None)        
        recid = form.getfirst('recid', None)
        self.logger.log('navigate() says recid is %s' % recid)
        new = form.get('newForm', None)
        self.save_form(req, loc, recid) 
        self.logger.log('after saving navigate() thinks recid is %s' % recid)  
        page = self.populate_form(recid, loc, new)    
        return page 
   
       
    def generate_form(self, req):
        structure = read_file('ead2002.html')
        doc = StringDocument('<ead><eadheader></eadheader><archdesc></archdesc></ead>')         
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw()
        paramDict = {
            '%REP_NAME%': repository_name, 
            '%REP_LINK%': repository_link,
            '%REP_LOGO%': repository_logo, 
            '%TITLE%': ' :: '.join(self.htmlTitle), 
            '%NAVBAR%': ' | '.join(self.htmlNav),
            '%FRM%' : htmlform,
        }
        page = multiReplace(structure, paramDict)
        #page = structure.replace('%FRM%', htmlform) 
        return page
    
    
    def handle (self, req):
        form = FieldStorage(req)        
        operation = form.get('operation', None)        
        if (operation == 'add'):  
            page = self.add_form(req)
            self.send_html(page, req)            
        elif (operation == 'navigate'):
            page = self.navigate(req)
            self.send_html(page, req)
        else :           
            page = self.generate_form(req)
            self.send_html(page, req)
    
        #- end handle() ---------------------------------------------------
        
    #- end class EadEditingHandler ----------------------------------------
    
#- Some stuff to do on initialisation

rebuild = True
serv = None
session = None
db = None
editStore = None
xmlp = None
formTxr = None
logfilepath = editinglogfilepath

def build_architecture(data=None):
    global session, serv, db, editStore, formTxr, xmlp
    #Discover objects
    session = Session()
    session.database = 'db_ead'
    session.environment = 'apache'
    session.user = None
    serv = SimpleServer(session, '/home/cheshire/cheshire3/cheshire3/configs/serverConfig.xml')
    db = serv.get_object(session, 'db_ead')
    editStore = db.get_object(session, 'editingStore')
    # transformers
    xmlp = db.get_object(session, 'LxmlParser')
    formTxr = db.get_object(session, 'formCreationTxr')
    rebuild = False





def handler(req):
    global rebuild, logfilepath, cheshirePath, db, editStore, xmlp, formTxr                # get the remote host's IP
    req.register_cleanup(build_architecture)
    
    try :
        try: 
            fp = editStore.get_path(session, 'databasePath')
            assert (rebuild)
            assert (os.path.exists(fp) and time.time() - os.stat(fp).st_mtime > 60*60)
        except :
            build_architecture()
      #  formTxr = db.get_object(session, 'formCreationTxr')    
        remote_host = req.get_remote_host(apache.REMOTE_NOLOOKUP)
        os.chdir(os.path.join(cheshirePath, 'cheshire3', 'www', 'ead', 'html'))     # cd to where html fragments are
        lgr = FileLogger(logfilepath, remote_host)                                  # initialise logger object
        eadEditingHandler = EadEditingHandler(lgr)                                      # initialise handler - with logger for this request
        try:
            eadEditingHandler.handle(req)   
        finally:
            try:
                lgr.flush()
            except:
                pass
            del lgr, eadEditingHandler  
  #  except (etree                                        # handle request
    except:
        req.content_type = "text/html"
        cgitb.Hook(file = req).handle()                                         # give error info
    else :
        return apache.OK

#- end handler()