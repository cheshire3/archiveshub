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


class EadEditingHandler:
    global repository_name, repository_link, repository_logo, htmlPath
    templatePath = os.path.join(htmlPath, 'template.ssi')

    htmlTitle = None
    htmlNav = None
    logger = None
    
    
    altrenderDict = { 'surname' : 'a',
                      'dates' : 'y',
                      'other' : 'x',
                      'loc' : 'z'                    
                     }
    
    textareas = ['bioghist', 'custodhist', 'acqinfo', 'scopecontent', 'appraisal', 'accruals', 'arrangement']

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
    
    def send_xml(self, data, req, code=200):
        req.content_type = 'text/xml'
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()
        
    #- end send_xml()
    
    
    def build_ead(self, req):
        self.logger.log('building ead')
        form = FieldStorage(req, True)
        ctype = form.get('ctype', None)
        level = form.get('location', None)
        collection = False;
        if (level == 'collectionLevel'):
            collection = True;
            tree = etree.fromstring('<ead><eadheader></eadheader><archdesc></archdesc></ead>')
        else :
            tree = etree.fromstring('<%s id="%s"></%s>' % (ctype, level, ctype))
        list = form.list     
        for field in list :
            if field.name not in ['ctype','location','operation','newForm','nocache','recid']:              
                #do did level stuff
                if (collection):
                    node = tree.xpath('/ead/archdesc')[0]
                else :
                    node = tree.xpath('/*[not(name() = "ead")]')[0]
                if field.name.find('controlaccess') == 0 :
                    self._create_controlaccess(node, field.name, field.value) 
                elif field.name.find('langusage') == 0 :
                    self._create_langusage(node, field.value)
                else :
                    if (field.value != ''):
                        target = self._create_path(node, field.name)
                        self._add_text(target, field.value)
        #raise ValueError(etree.tostring(tree))
        return tree    
    #- end build_ead
    
    
    def _delete_currentControlaccess(self, startNode, list=['subject','persname', 'famname', 'title', 'corpname', 'geogname', 'title']):
        if (startNode.xpath('controlaccess')):
            parent = startNode.xpath('controlaccess')[0]        
            for s in list :
                if (parent.xpath('%s' % s)) :
                    child = parent.xpath('%s' % s)
                    for c in child :
                        parent.remove(c)
            if len(parent.getchildren()) == 0 :
                startNode.remove(parent)
            
            
    def _delete_currentLangusage(self, startNode):
        if (startNode.xpath('langusage')):
            parent = startNode.xpath('langusage')[0]
            child = parent.xpath('language')
            if len(child) > 0 :
                for c in child :
                    parent.remove(c)
            startNode.remove(parent)
    
    
    def _create_langusage(self, startNode, value):
        if not (startNode.xpath('langusage')):
            langusage = etree.Element('langusage')
            startNode.append(langusage)
            luNode = langusage
        else:
            luNode = startNode.xpath('langusage')[0]
        fields = value.split(' ||| ')
        language = etree.SubElement(luNode, 'language', langcode='%s' % fields[0].split(' | ')[1])     
        text = fields[1].split(' | ')[1]
        language.text = text        
        
       
    def _create_controlaccess(self, startNode, name, value):
        if not (startNode.xpath('controlaccess')):
            controlaccess = etree.Element('controlaccess')
            startNode.append(controlaccess)
            caNode = controlaccess
        else:
            caNode = startNode.xpath('controlaccess')[0]   
        type = etree.Element(name[name.find('/')+1:])
        caNode.append(type)
        fields = value.split(' ||| ')
        for f in fields :
            if not (f == ''):
                field = f.split(' | ')
                typelabel = field[0].split('_')[0]
                fieldlabel = field[0].split('_')[1]
                if (fieldlabel == 'source' or fieldlabel == 'rules'):
                    type.set(fieldlabel, field[1])               
                else :
                    if (fieldlabel == typelabel):
                        attributeValue = 'a'
                    else:
                        attributeValue = self.altrenderDict.get(fieldlabel, None)
                        if attributeValue == None :
                            attributeValue = fieldlabel
                    emph = etree.Element('emph', altrender='%s' % attributeValue)
                    emph.text = field[1]  
                    type.append(emph)
    
    #- end _create_controlacess    
    
            
    def _delete_path(self, startNode, nodePath):
        if not (startNode.xpath(nodePath)) :
            return 
        elif (nodePath.find('/') == -1) :
            child = startNode.xpath(nodePath)[0]
            if len(child.getchildren()) == 0 :
                return self._remove_element(startNode, child)   
            else :
                paraCount = 0
                for c in child.getchildren():
                    if c.tag == 'p':
                        paraCount += 1
                if paraCount == len(child.getchildren()):
                     return self._remove_element(startNode, child) 
                else :  
                    return 
        else :
            child = startNode.xpath(nodePath)[0]
            parent = startNode.xpath(''.join(nodePath[:nodePath.rfind('/')]))[0]
            if len(child.getchildren()) == 0 :
                self._remove_element(parent, child)
                return self._delete_path(startNode, ''.join(nodePath[:nodePath.rfind('/')]))
            else :
                return 


    def _create_path(self, startNode, nodePath):               
        if (startNode.xpath(nodePath)):
            return startNode.xpath(nodePath)[0]
        elif (nodePath.find('/') == -1) :
            newNode = etree.Element(nodePath)                        
            return self._append_element(startNode, newNode)
        else :
            newNodePath = ''.join(nodePath[:nodePath.rfind('/')]) 
            nodeString = ''.join(nodePath[nodePath.rfind('/')+1:])  
            if (nodeString.find('@') != 0):      
                newNode = etree.Element(nodeString)
                return self._append_element(self._create_path(startNode, newNodePath), newNode)
            else:
                return self._add_attribute(self._create_path(startNode, newNodePath), nodeString[1:])
    
    
    def _remove_element(self, parentNode, childNode):
        parentNode.remove(childNode)
        return parentNode        
            
            
    def _append_element(self, parentNode, childNode):    
        parentNode.append(childNode)
        return childNode

    
    def _add_attribute(self, parentNode, attribute):
        parentNode.attrib[attribute] = ""
        return [parentNode, attribute]
 
        
    def _add_text(self, parent, textValue):
        if isinstance(parent, etree._Element):
            if parent.tag in self.textareas :
                for t in parent.getchildren():
                    parent.remove(t)
                paras = textValue.split('\n\n')
                for p in paras :
                    paragraph = etree.SubElement(parent, 'p')
                    self._create_textNode(paragraph, p)
            else :
                self._create_textNode(parent, textValue)
        else :
            parent[0].attrib[parent[1]] = textValue


    def _create_textNode(self, parent, value):
        #find all the tags create elements add their text and their tail add whole lot to parent 
        if (value.find('<') != -1 and value.find('>') != -1):
            open = value.find('<')
            close = value.find('>')
            if open != 0 :
                parent.text = value[:close]
            tagname = value[open+1:close]
            content = value[close+1:value.find('<', close)]
            newNode = etree.SubElement(parent, tagname)
            newNode.text = content
            if value[value.find('<', close)+1:value.find('<', close)+2] == '/' :
                pass
            else :
                newValue = value[value.find('>', close+2)+1:]
                self._create_textNode(newNode, newValue)
            #need to change the find things to specify a place to start
       
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
            node = tree[1].get(new)
            for e in tree[0].getiterator() :
                if e == node :
                    root = deepcopy(e)
            rec = LxmlRecord(root)                 
        return formTxr.process_record(session, rec).get_raw() 

    
    def save_form(self, req, loc, recid):
        form = FieldStorage(req, True)
        if (loc == 'collectionLevel' and (recid == None or recid == 'None')):
            #save the form in any free slot
            rec = LxmlRecord(self.build_ead(req))
            id = str(editStore.create_record(session, rec))
            recid = id.split('/')[1]
            editStore.commit_storing(session)   
            return recid
        elif (loc == 'collectionLevel'):          
            list = form.list  
            #pull existing xml and make into a tree
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedXml = retrievedRec.get_xml()
            tree = etree.fromstring(retrievedXml)
            #first delete current accesspoints
            node = tree.xpath('/ead/archdesc')[0]
            self._delete_currentControlaccess(node)
            self._delete_currentLangusage(node)
            #cycle through the form and replace any node that need it
            for field in list :
                if field.name not in ['ctype','location','operation','newForm','nocache','recid']:    
                    #TODO header stuff
                              
                    #do archdesc stuff
                    node = tree.xpath('/ead/archdesc')[0]  
                    if field.name.find('controlaccess') == 0 :                        
                        self._create_controlaccess(node, field.name, field.value)      
                    elif field.name.find('langusage') == 0 :
                        self._create_langusage(node, field.value)
                    else :
                        if (field.value.strip() != ''):
                            target = self._create_path(node, field.name)
                            self._add_text(target, field.value)       
                        else:
                            self._delete_path(node, field.name)     

            rec = LxmlRecord(tree)
            rec.id = retrievedRec.id
            editStore.store_record(session, rec)
            editStore.commit_storing(session)
#            raise ValueError(etree.tostring(tree))
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
                dsc = tree.xpath('/ead/archdesc/dsc')[0]
                dsc.append(self.build_ead(req))
                rec = LxmlRecord(tree)
                rec.id = retrievedRec.id
                editStore.store_record(session, rec)
                editStore.commit_storing(session) 
                
            #if the component does exist change it
            else :   
                list = form.list
                #first delete current accesspoints
                node = tree.xpath(xpathString)[0]
                self._delete_currentControlaccess(node)
                for field in list :
                    if field.name not in ['ctype','location','operation','newForm','nocache','recid']:             
                        node = tree.xpath(xpathString)[0]
                        if field.name.find('controlaccess') == 0 :                        
                            self._create_controlaccess(node, field.name, field.value)      
                        elif field.name.find('langusage') == 0 :
                            self._create_langusage(node, field.value)
                        else :
                            if (field.value.strip() != ''):
                                target = self._create_path(node, field.name)
                                self._add_text(target, field.value)       
                            else:
                                self._delete_path(node, field.name)   
                            
                rec = LxmlRecord(tree)
                rec.id = retrievedRec.id
                editStore.store_record(session, rec)
                editStore.commit_storing(session)

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
        new = form.get('newForm', None)
        self.save_form(req, loc, recid)  
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
    
    def display(self, req):
        form = FieldStorage(req)
        recid=form.get('recid', None)
        if recid != None and recid != 'null' :
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedxml= retrievedRec.get_xml()
            tree = etree.fromstring(retrievedxml)
            return etree.tostring(tree)
        else :
            return '<p>Unable to display xml</p>'
            
    
    def handle (self, req):
        form = FieldStorage(req)        
        operation = form.get('operation', None)        
        if (operation == 'add'):  
            page = self.add_form(req)
            self.send_html(page, req)            
        elif (operation == 'navigate'):
            page = self.navigate(req)
            self.send_html(page, req)
        elif (operation == 'display'):
            page = self.display(req)
            self.send_xml(page, req)
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