#
# Script:    eadEditingHandler.py
# Version:   0.1
# Date:      ongoing
# Copyright: &copy; University of Liverpool 2008
# Description:
#            Data creation and editing interface for EAD finding aids
#            - part of Cheshire for Archives v3
#
# Author(s): CS - Catherine Smith <catherine.smith@liv.ac.uk>
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




from eadHandler import *
from cheshire3.record import LxmlRecord
from copy import deepcopy
import datetime, glob
import traceback
import codecs

saveByUser = True


class EadEditingHandler(EadHandler):
    global repository_name, repository_link, repository_logo, htmlPath
    templatePath = os.path.join(htmlPath, 'template.ssi')
    
    htmlTitle = None
    htmlNav = None
    logger = None
    errorFields = []
    
    altrenderDict = { 'surname' : 'a',
                      'organisation' : 'a',
                      'dates' : 'y',
                      'other' : 'x',
                      'loc' : 'z'                    
                     }

    
    persnamePunct = {'a': [', '],
                     'forename': ['. '],
                     'y': ['(', ') '],
                     'epithet': [', ']
                     }
    
    famnamePunct = {'a': [' family. '],
                    'title':['. '],
                    'y': ['(', ') '],
                    'z':['. ']
                    }
    
    corpnamePunct = {'x': [' -- ', ' '],
                     'y': ['(', ') '],
                     'z': [' -- ', ' ']                            
                     }
    
    subjectPunct = {'x': [' -- ', ' '],
                     'y': [' -- ', ' '],
                     'z': [' -- ', ' ']                            
                     }
    
    locationPunct = {'x': [' -- ', ' ']
                     }

    typeDict = {'persname': persnamePunct, 'famname': famnamePunct, 'corpname': corpnamePunct, 'subject': subjectPunct, 'location': locationPunct}

    def __init__(self, lgr):
        EadHandler.__init__(self, lgr)
        self.htmlTitle = ['Data Creation and Editing']
        self.htmlNav = ['<a href="">Editing Menu</a>', '<a href="javascript: toggleKeyboard();">Character Keyboard</a>']
        self.logger = lgr
    #- end __init__ ---------------------------------------------------------


#this one possibly not used:

    def _get_depth (self, node):
        compre = re.compile('^c[0-9]*$')
        depth = 0;
        for element in node.iterancestors():
            if compre.match(element.tag) or element.tag == 'archdesc':
                depth += 1
        return depth            
    

    def send_fullHtml(self, data, req, code=200):
        tmpl = read_file(self.templatePath)                                     # read the template in
        page = tmpl.replace("%CONTENT%", data)
    
        self.globalReplacements.update({
            "%TITLE%": ' :: '.join(self.htmlTitle)
            ,"%NAVBAR%": ' | '.join(self.htmlNav),
        })
    
        page = multiReplace(page, self.globalReplacements)
        req.content_type = 'text/html'
        req.content_length = len(page)
        req.send_http_header()
        if (type(page) == unicode):
          page = page.encode('utf-8')
        req.write(page)
        req.flush()        
    #- end send_html() ---------------------------------------------------------
    
    
    def send_xml(self, data, req, code=200):
        req.content_type = 'text/xml'
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()       
    #- end send_xml() ---------------------------------------------------------
    

    def _validate_isadg(self, rec):
        required_xpaths = ['/ead/eadheader/eadid']
        # check record for presence of mandatory XPaths
        missing_xpaths = []
        for xp in required_xpaths:
            try: rec.process_xpath(session, xp)[0];
            except IndexError:
                missing_xpaths.append(xp)
        if len(missing_xpaths):
            self.htmlTitle.append('Error')
            newlineRe = re.compile('(\s\s+)')
            return '''
    <p class="error">Your file does not contain the following mandatory XPath(s):<br/>
    %s
    </p>
    <pre>
    %s
    </pre>
    ''' % ('<br/>'.join(missing_xpaths), newlineRe.sub('\n\g<1>', html_encode(rec.get_xml(session))))
        else:
            return None
    # end _validate_isadg() ---------------------------------------------------------
    
    


# EAD Creation and Editing Functions ==========================================================================================
    
    def build_ead(self, form):
        self.logger.log('building ead')
        ctype = form.get('ctype', None)
        level = form.get('location', None)
        collection = False;
        if (level == 'collectionLevel'):
            collection = True;
            tree = etree.fromstring('<ead><eadheader></eadheader><archdesc></archdesc></ead>')           
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header, 'eadid')
            if form.get('eadid', '') != '':
                self._add_text(target, form.get('eadid', ''))
            else :
                self._add_text(target, form.get('pui', ''))
            target = self._create_path(header, 'filedesc/titlestmt/titleproper')
            self._add_text(target, form.get('did/unittitle', ''))     
            if form.get('filedesc/titlestmt/sponsor', '') != '': 
                target = self._create_path(header, 'filedesc/titlestmt/sponsor')   
                self._add_text(target, form.get('filedesc/titlestmt/sponsor', '')) 
            target = self._create_path(header, 'profiledesc/creation')
            if session.user.realName != '' :
                userName = session.user.realName
            else :
                userName = session.user.username
            self._add_text(target, 'Created by %s using the cheshire for archives ead creation tool ' % userName)
            target = self._create_path(header, 'profiledesc/creation/date')
            self._add_text(target, '%s' % datetime.date.today())
        else :
            tree = etree.fromstring('<%s id="%s"></%s>' % (ctype, level, ctype))           
        list = form.list     
        for field in list :
            if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent', 'pui', 'eadid', 'filedesc/titlestmt/sponsor']:        
                #do did level stuff
                if (collection):
                    node = tree.xpath('/ead/archdesc')[0]
                else :
                    node = tree.xpath('/*[not(name() = "ead")]')[0]
                if field.name.find('controlaccess') == 0 :
                    self._create_controlaccess(node, field.name, field.value) 
                elif field.name.find('did/langmaterial') == 0 :
                    did = self._create_path(node, 'did')
                    self._create_langmaterial(did, field.value)
                else :
                    if (field.value.strip() != '' and field.value.strip() != ' '):
                        target = self._create_path(node, field.name)
                        self._add_text(target, field.value)
        self.logger.log('build complete')
        return tree    
    #- end build_ead    
        
            
    def _delete_path(self, startNode, nodePath):
        if not (startNode.xpath(nodePath)) :
            return 
        else :
            child = startNode.xpath(nodePath)[0]
            if nodePath.find('/') == -1 :
                parent = startNode
            else :
                parent = parent = startNode.xpath(''.join(nodePath[:nodePath.rfind('/')]))[0]
            parent.remove(child)
            if len(parent.getchildren()) > 0 :
                return
            else :
                return self._delete_path(startNode, nodePath[:nodePath.rfind('/')])
            

    def _create_path(self, startNode, nodePath):              
        if (startNode.xpath(nodePath)):
            if (nodePath.find('@') == -1):
                return startNode.xpath(nodePath)[0]
            else :  
                if len(startNode.xpath(nodePath[:nodePath.rfind('/')])) > 0:
                    parent = startNode.xpath(nodePath[:nodePath.rfind('/')])[0]
                else :
                    parent = startNode
                attribute = nodePath[nodePath.rfind('@')+1:]
                return [parent, attribute]
        elif (nodePath.find('@') == 0):
            return self._add_attribute(startNode, nodePath[1:])
        elif (nodePath.find('/') == -1) :
            if nodePath.find('[') != -1 :
                newNode = etree.Element(nodePath[:nodePath.find('[')])   
            else :
                newNode = etree.Element(nodePath)                     
            return self._append_element(startNode, newNode)
        else :
            newNodePath = ''.join(nodePath[:nodePath.rfind('/')]) 
            nodeString = ''.join(nodePath[nodePath.rfind('/')+1:])  
            if (nodeString.find('@') != 0):      
                if nodeString.find('[') != -1 :
                    newNode = etree.Element(nodeString[:nodeString.find('[')])
                else :
                    newNode = etree.Element(nodeString)
                return self._append_element(self._create_path(startNode, newNodePath), newNode)
            else:
                return self._add_attribute(self._create_path(startNode, newNodePath), nodeString[1:])  
            
                        
    def _append_element(self, parentNode, childNode):    
        parentNode.append(childNode)
        return childNode

    
    def _add_attribute(self, parentNode, attribute):
        parentNode.attrib[attribute] = ""
        return [parentNode, attribute]

       
    def _delete_currentControlaccess(self, startNode, list=['subject','persname', 'famname', 'corpname', 'geogname', 'title', 'genreform']):
        if (startNode.xpath('controlaccess')):
            self.logger.log('deleting control access')
            parent = startNode.xpath('controlaccess')[0]        
            for s in list :
                if (parent.xpath('%s' % s)) :
                    child = parent.xpath('%s' % s)
                    for c in child :
                        parent.remove(c)
            if len(parent.getchildren()) == 0 :
                startNode.remove(parent)
            
                
    def _delete_currentLangmaterial(self, startNode):
        did = startNode.xpath('did')[0]
        if (did.xpath('langmaterial')):
            parent = did.xpath('langmaterial')[0]
            child = parent.xpath('language')
            if len(child) > 0 :
                for c in child :
                    parent.remove(c)
            did.remove(parent)
    
      
    def _create_langmaterial(self, startNode, value, name=None):
        if not (startNode.xpath('langmaterial')):
            langmaterial = etree.Element('langmaterial')
            startNode.append(langmaterial)
            lmNode = langmaterial
        else:
            lmNode = startNode.xpath('langmaterial')[0]           
        fields = value.split(' ||| ')
        language = etree.SubElement(lmNode, 'language', langcode='%s' % fields[0].split(' | ')[1])     
        text = fields[1].split(' | ')[1]
        language.text = text     


    def _add_text(self, parent, textValue):
        if not (textValue.find('&amp;') == -1):
            textValue = textValue.replace('&amp;', '&#38;')
        else : 
            if not (textValue.find('&') == -1):
                textValue = textValue.replace('&', '&#38;')
        textValue = textValue.lstrip()      
        if isinstance(parent, etree._Element):
            for c in parent.getchildren() :
                parent.remove(c)
            value = '<foo>%s</foo>' % textValue      
            try :
                nodetree = etree.fromstring(value)               
            except :
                self.errorFields.append(parent.tag)
                parent.text = textValue
            else :
                parent.text = nodetree.text
                for n in nodetree :
                    parent.append(n)
        else :
            parent[0].attrib[parent[1]] = textValue
       
       
    def _create_controlaccess(self, startNode, name, value):
        #get the controlaccess node or create it 
        if not (startNode.xpath('controlaccess')):
            controlaccess = etree.Element('controlaccess')
            #need to insert before dsc?
            startNode.append(controlaccess)
            caNode = controlaccess
        else:
            caNode = startNode.xpath('controlaccess')[0]   
        typeString = name[name.find('/')+1:]    
        type = etree.Element(typeString)
        
        caNode.append(type)
        fields = value.split(' ||| ')
        for i, f in enumerate(fields) :
            if not (f == ''):
                field = f.split(' | ')
                typelabel = field[0].split('_')[0]
                fieldlabel = field[0].split('_')[1]
                if (fieldlabel == 'source' or fieldlabel == 'rules' or typelabel == 'att'):
                    if (field[1] != 'none') :
                        type.set(fieldlabel, field[1])                         
                else :
                    try:
                        punctList = self.typeDict[typeString]
                    except:
                        punctList = None                      
                    if (fieldlabel == typelabel):
                        attributeValue = 'a'
                    else:
                        attributeValue = self.altrenderDict.get(fieldlabel, None)
                        if attributeValue == None :
                            attributeValue = fieldlabel
                    emph = etree.Element('emph', altrender='%s' % attributeValue)
                    self._add_text(emph, field[1])
                    if i < len(fields):
                        if punctList and punctList.get(attributeValue, None):
                            punct = punctList.get(attributeValue, None)
                            if len(punct) == 1:
                                emph.tail = punct[0]
                            else:
                                type[-1].tail = '%s%s' % (type[-1].tail, punct[0])
                                emph.tail = punct[1]
                        else:
                            emph.tail = ' '
                    type.append(emph)    
        lastTail = type[-1].tail   
        if re.match('(\s+)?[,\.\-](\s+)?', lastTail):
            type[-1].tail = ''
         
    #- end _create_controlacess    
 
 
# ========================================================================================

# Navigation related functions ==================================================================
       
    def navigate(self, form):    
        recid = form.get('recid', None)
        owner = form.get('owner', session.user.username)
        new = form.get('newForm', None)
        page = self.populate_form(recid, owner, new, form)  
        return page    
    
    def populate_form(self, recid, owner, new, form):  
        #if its collection level give the transformer the whole record
        if (new == 'collectionLevel'):  
            retrievedDom = editStore.fetch_record(session, '%s-%s' % (recid, owner)).get_dom(session)
            rec = LxmlRecord(retrievedDom)
           
        #if its a component find the component by id and just give that component to the transformer          
        else :
            retrievedXml = editStore.fetch_record(session, '%s-%s' % (recid, owner)).get_xml(session)
            root = None
            tree = etree.XMLID(retrievedXml)
            node = tree[1].get(new)                
            for e in tree[0].getiterator() :
                if e == node :
                    root = deepcopy(e)
            
            if root == None :
                ctype = form.get('ctype', 'c')
                doc = StringDocument('<%s><recid>%s</recid></%s>' % (ctype, recid, ctype))
                rec = xmlp.process_document(session, doc)
            else :
                rec = LxmlRecord(root) 
        
        page = formTxr.process_record(session, rec).get_raw(session)
        page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" disabled="true" value="%s"/>' % recid)
        return page.replace('%RECID%', '')


# loading in related functions =============================================================================
    
    def _add_componentIds (self, rec):
        tree = etree.fromstring(rec.get_xml(session))
        compre = re.compile('^c[0-9]*$')
        for element in tree.iter(tag=etree.Element):
            if compre.match(element.tag): 
                try :                 
                    if not element.get('id'):
                        #add the appropriate id!
                        posCount = 1
                        parentId = ''
                        for el in element.itersiblings(tag=etree.Element, preceding=True):
                            if compre.match(el.tag):
                                posCount += 1
                        #get the parent component id and use it 
                        for el in element.iterancestors():
                            if compre.match(el.tag):
                                parentId = el.get('id')                             
                                break
                        idString = '%d-%s' % (posCount, parentId)
                        if idString[-1] == '-':
                            idString = idString[:-1]
                        element.set('id', idString)                       
                except :
                    raise
        return LxmlRecord(tree)
                    
                     
    def generate_file(self, form):
        structure = read_file('ead2002.html')
        doc = StringDocument('<ead><eadheader></eadheader><archdesc></archdesc></ead>')      
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        page = structure.replace('%FRM%', htmlform) 
        page = page.replace('%RECID%', '<input type="hidden" id="recid" value="notSet"/>')
        page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" readonly="true" class="readonly"/>')
        page = page.replace('%TOC%', '<b><a id="collectionLevel" name="link" class="selected" onclick="javascript: displayForm(this.id)" href="#" style="display: inline">Collection Level</a></b>')  
        return page
  
    
    def _add_revisionDesc(self, rec, fn):
        tree = rec.get_dom(session)
        filename = fn[fn.rfind('/data/')+6:]
        if session.user.realName != '' :
            userName = session.user.realName
        else :
            userName = session.user.username
        if tree.xpath('/ead/eadheader/revisiondesc'):
           
            if tree.xpath('/ead/eadheader/revisiondesc/change'):
                parent = tree.xpath('/ead/eadheader/revisiondesc')[0]
                new = etree.Element('change')
                date = etree.Element('date')
                date.text = '%s' % datetime.date.today()
                new.append(date)
                item = etree.Element('item')
                item.text = 'Loaded from %s and edited by %s using the cheshire for archives ead creation tool' % (filename, userName)
                new.set('audience', 'internal')
                new.append(item)
                parent.append(new)
            elif tree.xpath('/ead/eadheader/revisiondesc/list'):
                parent = tree.xpath('/ead/eadheader/revisiondesc/list')[0]
                item = etree.Element('item')
                item.set('audience', 'internal')
                item.text = 'Loaded from %s and edited by %s using the cheshire for archives ead creation tool on %s'  % (filename, userName, datetime.date.today())
                parent.append(item)
        else :
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header, '/ead/eadheader/revisiondesc/change')
            target.set('audience', 'internal')
            target = self._create_path(header, '/ead/eadheader/revisiondesc/change/date')
            self._add_text(target, '%s' % datetime.date.today())
            target = self._create_path(header, '/ead/eadheader/revisiondesc/change/item')          
            self._add_text(target, 'Loaded from %s and edited by %s using the cheshire for archives ead creation tool' % (filename, userName))   
        return LxmlRecord(tree)


            
    #loads from editStore
    def load_file(self, form):
        recid = form.get('recid', None)
        if not recid :
            return self.show_editMenu();
        try :
            rec = editStore.fetch_record(session, recid)
        except:
            #to do - fix this
            pass
        else :
            structure = read_file('ead2002.html') 
            htmlform = formTxr.process_record(session, rec).get_raw(session)
            page = structure.replace('%FRM%', htmlform) 
            splitId = recid.split('-')
            page = page.replace('%RECID%', '<input type="hidden" id="recid" value="%s"/>' % splitId[0])
            if splitId[1] == session.user.username:
                page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" disabled="true" value="%s"/>' % splitId[0])
            else :
                page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" disabled="true" value="%s"/><input type="hidden" id="owner" value="%s"/>' % (splitId[0], splitId[1]))
            page = page.replace('%TOC%', tocTxr.process_record(session, rec).get_raw(session))
            return page
        
    #loads from recordStore
    def edit_file(self, form):
        f = form.get('filepath', None)
        if not f or not len(f.value):
            return self.show_editMenu();
        ws = re.compile('[\s]+')
        xml = ws.sub(' ', read_file(f))
        rec = self._add_componentIds(self._parse_upload(xml))       
        # TODO: handle file not successfully parsed
        if not isinstance(rec, LxmlRecord):
            return rec
        
        val = self._validate_isadg(rec)
        if (val): return val
        del val      
        
        #add necessary information to record and save in editStore with id 'recid-username'
        rec1 = self._add_revisionDesc(rec, f)
        rec2 = assignDataIdFlow.process(session, rec1)
        recid = rec2.id
        rec2.id = '%s-%s' % (recid, session.user.username.encode('ascii', 'ignore'))
        editStore.store_record(session, rec2)
        editStore.commit_storing(session) 
        
        structure = read_file('ead2002.html')
        htmlform = formTxr.process_record(session, rec2).get_raw(session)
        page = structure.replace('%FRM%', htmlform)
        page = page.replace('%RECID%', '<input type="hidden" id="recid" value="%s"/>' % (recid.encode('ascii')))
        page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" disabled="true" value="%s"/><input type="hidden" id="filename" value="%s"/>' % (recid.encode('ascii'), f))
        page = page.replace('%TOC%', tocTxr.process_record(session, rec2).get_raw(session))
        return page    
    
    
    def _get_timeStamp(self):
        return time.strftime('%Y-%m-%dT%H%M%S')
    
    
# Validation related functions   ================================================================================== 
    
    
    def getAndCheckId(self, form):
        f = form.get('filepath', None)
        if not f or not len(f.value):
            #TODO: create appropriate html file - this is for admin
            return read_file('upload.html')
        ws = re.compile('[\s]+')
        xml = ws.sub(' ', read_file(f))
        rec = self._add_componentIds(self._parse_upload(xml))
                
        # TODO: handle file not successfully parsed
        if not isinstance(rec, LxmlRecord):
            return rec
        
        val = self._validate_isadg(rec)
        if (val): return val
        del val      
        
        rec = assignDataIdFlow.process(session, rec)
        names = []
        for r in editStore:
            if r.id[:r.id.rfind('-')] == rec.id :
                names.append(r.id[r.id.rfind('-')+1:])
        if len(names) == 0:
            return '<value>false</value>'
        else :
            ns = []
            for n in names:
                if n != session.user.username :
                    ns.append(n)
            if len(names) == 1 and names[0] == session.user.username :
                return '<wrap><value>true</value><overwrite>true</overwrite></wrap>'
            elif len(names) > 1 and session.user.username in names :
                return '<wrap><value>true</value><overwrite>true</overwrite><users>%s</users></wrap>' % ' \n '.join(ns)
            else :
                return '<wrap><value>true</value><overwrite>false</overwrite><users>%s</users></wrap>' % ' \n '.join(ns)
                
     
    def checkId(self, form):
        id = form.get('id', None)        
        store = form.get('store', None)
        
        if store == 'recordStore' :
            rs = recordStore
        elif store == 'editStore' :
            rs = editStore
        if (id != None and store != None):
            exists = 'false'
            for r in rs:
                if r.id == id :
                    exists = 'true'
                    break;
            return '<value>%s</value>' % exists
    
    
    def validate_record(self, xml):
        try :
            etree.fromstring(xml)
            return True
        except :
            return False
        
        
    def validateField(self, form):
        self.logger.log('validating field via AJAX')
        text = form.get('text', None)
        if not text.find('<') == -1:
            try :
                test = etree.fromstring('<foo>%s</foo>' % text)
                return '<value>true</value>'
            except :
                return '<value>false</value>'
        else :
            return '<value>true</value>'
    
    
    def _get_genericHtml(self, fn):
        global repository_name, repository_link, repository_logo
        html = read_file(fn)
        paramDict = self.globalReplacements
        paramDict.update({'%TITLE%': ' :: '.join(self.htmlTitle)
                         ,'%NAVBAR%': ' | '.join(self.htmlNav)
                         })
        return multiReplace(html, paramDict)
    
    
# Basic User functions - submit preview etc. ================================================================================


    def save_form(self, form):
        loc = form.get('location', None)
        recid = form.get('recid', None)
        parent = form.get('parent', None)
        fileOwner = form.get('owner', session.user.username)
        #if there this is a new collection level file
        if (loc == 'collectionLevel' and (recid == None or recid == 'None')):
            self.logger.log('new collection level')
            #save the form in any free slot
            rec = LxmlRecord(self.build_ead(form))
            rec = assignDataIdFlow.process(session, rec)
            recid = rec.id
            rec.id = '%s-%s' % (rec.id, fileOwner)
            editStore.store_record(session, rec)
            editStore.commit_storing(session) 
            return recid
        #this is an existing collection level file
        elif (loc == 'collectionLevel'):
            list = form.list  
            #pull existing xml and make into a tree
            retrievedRec = editStore.fetch_record(session, '%s-%s' % (recid, fileOwner))
            retrievedXml = retrievedRec.get_xml(session)
            self.logger.log('existing collection level')
            tree = etree.fromstring(retrievedXml)
            
            node = tree.xpath('/ead/archdesc')[0]         
            #first delete current accesspoints
            self._delete_currentControlaccess(node)
            self._delete_currentLangmaterial(node)
            self.logger.log('deleted stuff')
            #change title in header             
            header = tree.xpath('/ead/eadheader')[0]
            if form.get('filedesc/titlestmt/sponsor', '').value.strip() != '' and form.get('filedesc/titlestmt/sponsor', '').value.strip() != ' ': 
                target = self._create_path(header, 'filedesc/titlestmt/sponsor')
                self._add_text(target, form.get('filedesc/titlestmt/sponsor', ''))
            else :
                self._delete_path(node, 'filedesc/titlestmt/sponsor')
#CHECK THAT THIS IS SOMETHING WE WANT IF SO COMMENT IN AND TEST
            
            #target = self._create_path(header, 'titlestmt/titleproper')
            #self._add_text(target, form.get('did/unittitle', ''))
            
            
            #cycle through the form and replace any node that need it
            for field in list :                
                if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent', 'pui', 'filedesc/titlestmt/sponsor']:               
                    #do archdesc stuff
                    if field.name.find('controlaccess') == 0 :                        
                        self._create_controlaccess(node, field.name, field.value)      
                    elif field.name.find('did/langmaterial') == 0 :     
                        if field.name.find('did/langmaterial/@') == 0:
                            target = self._create_path(node, field.name)
                            self._add_text(target, field.value)
                        else:
                            did = self._create_path(node, 'did')
                            self._create_langmaterial(did, field.value)
                    else :
                        if (field.value.strip() != '' and field.value.strip() != ' '):
                            target = self._create_path(node, field.name)
                            self._add_text(target, field.value)       
                        else:
                            self._delete_path(node, field.name)              
            rec = LxmlRecord(tree)
            rec.id = retrievedRec.id
            editStore.store_record(session, rec)
            editStore.commit_storing(session)
            return recid       
        #check if C exists, if not add it, if so replace it
        else :
            self.logger.log('component')
            #pull record from store            
            retrievedRec = editStore.fetch_record(session, '%s-%s' % (recid, fileOwner))
            retrievedxml= retrievedRec.get_xml(session)
            tree = etree.XMLID(retrievedxml)            
            #first check there is a dsc element and if not add one (needed for next set of xpath tests)
            self.logger.log('testing dsc exists')
            
            if not (tree[0].xpath('/ead/archdesc/dsc')):
                self.logger.log('dsc does not exist')
                archdesc = tree[0].xpath('/ead/archdesc')[0]    
                dsc = etree.Element('dsc')     
                archdesc.append(dsc)    

            #if the component does not exist add it
            if not (tree[1].get(loc)):
                self.logger.log('new component')
                self.logger.log('parent is %s' % parent)
                if parent == 'collectionLevel' :
                    parentNode = tree[0].xpath('/ead/archdesc/dsc')[0]
                else :
                    parentNode = tree[1].get(parent)
                parentNode.append(self.build_ead(form))
                rec = LxmlRecord(tree[0])
                rec.id = retrievedRec.id
                editStore.store_record(session, rec)
                editStore.commit_storing(session)   
                                             
            #if the component does exist change it
            else :   
                self.logger.log('existing component')
                list = form.list
                node = tree[1].get(loc) 
                #first delete current accesspoints
                self._delete_currentControlaccess(node)
                self._delete_currentLangmaterial(node)
                self.logger.log('deleted stuff')
                for field in list :
                    if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent']:           
                        if field.name.find('controlaccess') == 0 :                        
                            self._create_controlaccess(node, field.name, field.value)      
                        elif field.name.find('did/langmaterial') == 0 :
                            if field.name.find('did/langmaterial/@') == 0:
                                target = self._create_path(node, field.name)
                                self._add_text(target, field.value)
                            else:
                                did = self._create_path(node, 'did')
                                self._create_langmaterial(did, field.value)
                        else :
                            if (field.value.strip() != '' and field.value.strip() != ' '):
                                target = self._create_path(node, field.name)
                                self._add_text(target, field.value)       
                            else:
                                self._delete_path(node, field.name)                              
                rec = LxmlRecord(tree[0])
                rec.id = retrievedRec.id
                editStore.store_record(session, rec)
                editStore.commit_storing(session)
            return recid    
  

    def delete_record(self, form):
        recid = form.get('recid', None)
        if not recid == None :
            editStore.delete_record(session, recid)
        return 'done'  


    def preview_file(self, req):
        global session, repository_name, repository_link, repository_logo, cache_path, cache_url, toc_cache_path, toc_cache_url, toc_scripts, script, fullTxr, fullSplitTxr
        form = FieldStorage(req)
        self.htmlTitle.append('Preview File')
        self.htmlNav.append('<a href="/ead/admin/files.html" title="Preview File" class="navlink">Files</a>')
        try :
            files = glob.glob('%s/preview/%s.*' % (toc_cache_path, session.user.username))
            for f in files :
                os.remove(f)
        except:
            pass
        try:          
            files = glob.glob('%s/preview/%s*' % (cache_path, session.user.username))
            for f in files :
                os.remove(f)
        except:
            pass
        pagenum = int(form.getfirst('pagenum', 1))
        
        self.logger.log('Preview requested')

        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        if recid != None and recid != 'null' :
            rec = editStore.fetch_record(session, '%s-%s' % (recid, fileOwner))
        if not isinstance(rec, LxmlRecord):
            return rec      
        # ensure restricted access directory exists
        try:
            os.makedirs(os.path.join(cache_path, 'preview'))
            os.makedirs(os.path.join(toc_cache_path, 'preview'))
        except OSError:
            pass # already exists

        recid = rec.id = 'preview/%s' % (session.user.username)    # assign rec.id so that html is stored in a restricted access directory
        paramDict = self.globalReplacements
        paramDict.update({'%TITLE%': ' :: '.join(self.htmlTitle)
                         ,'%NAVBAR%': ' | '.join(self.htmlNav)
                         ,'LINKTOPARENT': ''
                         ,'TOC_CACHE_URL' : toc_cache_url
                         , 'RECID': recid
                         })
        try:
            page = self.display_full(rec, paramDict)[pagenum-1]
        except IndexError:
            return 'No page number %d' % pagenum
        
        if not (os.path.exists('%s/%s.inc' % (toc_cache_path, recid))):
            page = page.replace('<!--#include virtual="%s/%s.inc"-->' % (toc_cache_url, recid), 'There is no Table of Contents for this file.')
        else:
            # cannot use Server-Side Includes in script generated pages - insert ToC manually
            try:
                page = page.replace('<!--#include virtual="%s/%s.inc"-->' % (toc_cache_url, recid), read_file('%s/%s.inc' % (toc_cache_path, recid)))
            except:
                page = page.replace('<!--#include virtual="%s/%s.inc"-->' % (toc_cache_url, recid), '<span class="error">There was a problem whilst generating the Table of Contents</span>')
 
        return page
    #- end preview_file() ---------------------------------------------------------


    def display(self, req):
        form = FieldStorage(req)
        recid=form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        if recid != None and recid != 'null' :
            retrievedRec = editStore.fetch_record(session, '%s-%s' % (recid, fileOwner))
            return orderTxr.process_record(session, retrievedRec).get_raw(session)
        else :
            return '<p>Unable to display xml</p>'
    
    
    def submit(self, req, form):
        global sourceDir, ppFlow, xmlp
        req.content_type = 'text/html'
        req.send_http_header()
        head = self._get_genericHtml('header.html')
        req.write(head)
        i = form.get('index', 'true')
        if i == 'false' :
            index = False
        else :
            index = True
        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        editRecid = '%s-%s' % (recid.value, fileOwner)
        
        rec = editStore.fetch_record(session, editRecid)
        
        filename = form.get('filename', self._get_filename(rec))
        if filename == None:
            filename = '%s.xml' % recid
        
        xml = rec.get_xml(session)    
        valid = self.validate_record(xml)     
        exists = True 
        if valid and index:
            #delete and unindex the old version from the record store
            try : 
                oldRec = recordStore.fetch_record(session, recid)
            except :
                #this is a new record so we don't need to delete anything
                exists = False
                req.write('<span class="error">[ERROR]</span> - Record not present in recordStore<br/>\n')
            else :
                req.write('undindexing existing version of record... ')
                db.unindex_record(session, oldRec)
                req.write('record unindexed')
                db.remove_record(session, oldRec)
                req.write('<span class="ok">[OK]</span><br/>\nDeleting record from stores ...')
                
                recordStore.begin_storing(session)
                recordStore.delete_record(session, oldRec.id)
                recordStore.commit_storing(session)
                
                dcRecordStore.begin_storing(session)
                try: dcRecordStore.delete_record(session, rec.id)
                except: pass
                else: dcRecordStore.commit_storing(session)
                req.write('[OK]')
                if len(rec.process_xpath(session, 'dsc')) and exists :
                    # now the tricky bit - component records
                    compStore.begin_storing(session)
                    q = CQLParser.parse('ead.parentid exact "%s/%s"' % (oldRec.recordStore, oldRec.id))
                    req.write('ead.parentid exact "%s/%s"' % (oldRec.recordStore, oldRec.id))
                    req.write('Removing components')
                    rs = db.search(session, q)
                    for r in rs:
                        try:
                            compRec = r.fetch_record(session)
                        except (c3errors.FileDoesNotExistException, c3errors.ObjectDoesNotExistException):
                            pass
                        else:
                            db.unindex_record(session, compRec)
                            db.remove_record(session, compRec)
                            compStore.delete_record(session, compRec.id)
         
                    compStore.commit_storing(session)
                    req.write('components removed')
            #add and index new record
            req.write('indexing new record... ')
            doc = ppFlow.process(session, StringDocument(xml))
            rec = xmlp.process_document(session, doc)
            assignDataIdFlow.process(session, rec)
            
            db.begin_indexing(session)
            recordStore.begin_storing(session)
            dcRecordStore.begin_storing(session)
            
            indexNewRecordFlow.process(session, rec)
            
            recordStore.commit_storing(session)
            dcRecordStore.commit_storing(session)
            
            
            if len(rec.process_xpath(session, 'dsc')):
                compStore.begin_storing(session)
                # extract and index components
                compRecordFlow.process(session, rec)
                compStore.commit_storing(session)
                db.commit_indexing(session)
                db.commit_metadata(session)
                req.write('[OK]')
            else :
                db.commit_indexing(session)
                db.commit_metadata(session)   
                req.write('[OK]')
            # write to file
        if valid:
            req.write('writing to file system... ')
            filepath = os.path.join(sourceDir, filename)
            if os.path.exists(filepath):
                os.remove(filepath)
            try :
                file = open(filepath, 'w')
            except :
                file = open(os.path.join(sourceDir,'%s.xml' % recid), 'w')
                
            tempRec = xmlp.process_document(session, orderTxr.process_record(session, rec))
            indentTxr = db.get_object(session, 'indentingTxr')
            file.write(indentTxr.process_record(session, tempRec).get_raw(session))
            file.close     
            editStore.delete_record(session, editRecid)
            editStore.commit_storing(session)
            req.write('\n<p><a href="/ead/admin/files.html">Back to \'File Management\' page.</a></p>')
            foot = self._get_genericHtml('footer.html')          
            req.write('</div>' + foot)
        return None 
      
      
    def _get_filename(self, rec):
        tree = rec.get_dom(session)
        if tree.xpath('/ead/eadheader/revisiondesc'):          
            if tree.xpath('/ead/eadheader/revisiondesc/change'):
                children = tree.xpath('/ead/eadheader/revisiondesc/change/item')
            elif tree.xpath('/ead/eadheader/revisiondesc/list'):
                children = tree.xpath('/ead/eadheader/revisiondesc/list/item')
            fnre = re.compile('Loaded from ([\S]+) and edited')
            m = re.match(fnre, children[-1].text)
            filename = m.group(1)
            return filename
        else :
            return None
      
    
    def add_form(self, form):
        recid = form.get('recid', None)
        level = int(form.get('clevel', None))
        stringLevel = '%02d' % (level)
        doc = StringDocument('<c%s><recid>%s</recid></c%s>' % (stringLevel, recid, stringLevel))
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        htmlform = htmlform.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" disabled="true" value="%s"/>' % recid)
        return htmlform


    def reset(self, form):
        doc = StringDocument('<ead><eadheader></eadheader><archdesc></archdesc></ead>')         
        rec = xmlp.process_document(session, doc)
        page = formTxr.process_record(session, rec).get_raw(session)
        page = page.replace('%RECID%', '<input type="hidden" id="recid" value="notSet"/>')
        page = page.replace('%PUI%', '<input type="text" onfocus="setCurrent(this);" name="pui" id="pui" size="30" readonly="true" class="readonly"/>')        
        return page



# Menu page functions ==============================================================================   
    
    
    def reassign_record(self, form):
        newUser = form.get('user', None).value
        recid = form.get('recid', None).value
        rec = editStore.fetch_record(session, recid)
        if rec.id[rec.id.rfind('-')+1:] == newUser :
            return recid
        else :
            rec.id = ('%s-%s') % (rec.id[:rec.id.rfind('-')], newUser)
            editStore.delete_record(session, recid)
            id = editStore.store_record(session, rec)           
            editStore.commit_storing(session) 
            return rec.id

         
    def show_editMenu(self):
        global sourceDir
        self.logger.log('Create/Edit Options')
        page = read_file('editmenu.html')
        userStore = db.get_object(session, 'eadAuthStore')
        files = self._walk_directory(sourceDir, 'radio')
        recids = self._walk_store('editingStore', 'radio', 'eadAuthStore')  
        if session.user.has_flag(session, 'info:srw/operation/1/create', 'eadAuthStore'):
            users = []
            for user in userStore :
                users.append('<option value="%s">%s</option>' % (user.username, user.username))
            assignmentOptn = '<select name="user"><option value="null">Reasign to...</option>%s</select><input type="button" onclick="reassignToUser()" value=" Confirm Reassignment "/>' % ''.join(users)
        else :
            assignmentOptn = ''
        return multiReplace(page, {'%%%SOURCEDIR%%%': sourceDir, '%%%FILES%%%': ''.join(files), '%%%RECORDS%%%': ''.join(recids), '%%%USROPTNS%%%': assignmentOptn})
       
             
    def _walk_store(self, storeName, type='checkbox', userStore=None):
        store = db.get_object(session, storeName)
        if not userStore:
            out = []
            for s in store :
                out.extend(['<li>'
                           ,'<span class="fileops"><input type="%s" name="recid" value="%s"/></span>' % (type, s.id)
                           ,'<span class="filename">%s</span>' % s.id
                           ,'</li>'
                           ])
            return out
        else :
            out = []
            names = []
            userStore = db.get_object(session, userStore)
            total = 0;
            for user in userStore :
                name = user.username
                names.append(name)
                if name == session.user.username or session.user.has_flag(session, 'info:srw/operation/1/create', 'eadAuthStore'):
                    disabled = ''
                else :
                    disabled = 'disabled="disabled"'
                userFiles = ['<li title=%s><span>%s</span>' % (name, name), '<ul class="hierarchy">'] 
                for s in store:
                    if s.id[s.id.rfind('-')+1:] == name:
                        try :
                            displayId = s.id[:s.id.rindex('-')]
                        except:
                            displayId = s.id
                        userFiles.extend(['<li>'
                                           ,'<span class="fileops"><input type="%s" name="recid" value="%s" %s/></span>' % (type, s.id, disabled)
                                           ,'<span class="filename">%s</span>' % displayId
                                           ,'</li>'
                                           ])
                        total += 1;
                userFiles.append('</ul></li>')
                out.append(''.join(userFiles))
            if total < store.get_dbSize(session):
                if session.user.has_flag(session, 'info:srw/operation/1/create', 'eadAuthStore'):
                    disabled = ''
                else :
                    disabled = 'disabled="disabled"'
                for s in store:
                    if s.id[s.id.rfind('-')+1:] not in names:
                        try :
                            displayId = s.id[:s.id.rindex('-')]
                        except:
                            displayId = s.id
                        out.extend(['<li title=deletedUsers><span>Deleted Users</span>', '<ul class="hierarchy">', '<li>'
                                                   ,'<span class="fileops"><input type="%s" name="recid" value="%s" %s/></span>' % (type, s.id, disabled)
                                                   ,'<span class="filename">%s</span>' % displayId
                                                   ,'</li>'])
            return out
                

#================================================================================================================    
                                     
    def handle (self, req):
        global script
        form = FieldStorage(req, True)  
        tmpl = read_file(templatePath)
        content = None      
        operation = form.get('operation', None)
        if (operation) :     
            if (operation == 'add'):  
                content = self.add_form(form)   
                self.send_html(content, req)
            elif (operation == 'save'):
                content = self.save_form(form)
                self.send_xml('<recid>%s</recid>' % content, req)
            elif (operation == 'delete'):
                content = self.delete_record(form)
                self.send_xml('<recid>%s</recid>' % content, req)
            elif (operation == 'reassign'):
                content = self.reassign_record(form)
                self.send_xml('<recid>%s</recid>' % content, req)
            elif (operation == 'navigate'):
                content = self.navigate(form)
                self.send_html(content, req)
            elif (operation == 'display'):
                content = self.display(req)
                self.send_xml(content, req)
            elif (operation == 'preview'):
                content = self.preview_file(req)
                self.send_html(content, req)     
            elif (operation == 'checkId'):
                content = self.checkId(form)
                self.send_xml(content, req)
            elif (operation == 'getCheckId'):
                content = self.getAndCheckId(form)
                self.send_xml(content, req)
            elif (operation == 'validate'):
                content = self.validateField(form)
                self.send_xml(content, req)  
            elif (operation == 'reset'):
                content = self.reset(form)
                self.send_html(content, req)
            elif (operation == 'view'):
                content = self.view_file(form)   
                self.send_fullHtml(content, req)         
            elif (operation == 'submit'):
                content = self.submit(req, form)
            elif (operation == 'edit'):                
                content = self.edit_file(form)
                self.send_fullHtml(content, req) 
            elif (operation == 'load'):
                content = self.load_file(form)
                self.send_fullHtml(content, req)             
            elif (operation == 'create'):
                content = self.generate_file(form)
                self.send_fullHtml(content, req) 
        else :              
            content = self.show_editMenu()
            page = multiReplace(tmpl, {'%REP_NAME%': repository_name,
                     '%REP_LINK%': repository_link,
                     '%REP_LOGO%': repository_logo,
                     '%TITLE%': ' :: '.join(self.htmlTitle),
                     '%NAVBAR%': '',#' | '.join(self.htmlNav),
                     '%CONTENT%': content
                     })

            # send the display
            self.send_html(page, req)
                     
    
        #- end handle() ---------------------------------------------------
        
    #- end class EadEditingHandler ----------------------------------------
    
#- Some stuff to do on initialisation

rebuild = True
serv = None
session = None
db = None
baseDocFac = None
sourceDir = None
editStore = None
recordStore = None
authStore = None
assignDataIdFlow = None
compRecordFlow = None
indexNewRecordFlow = None
preParserWorkflow = None
xmlp = None
formTxr = None
tocTxr = None
orderTxr = None
logfilepath = editinglogfilepath


def build_architecture(data=None):
    global session, serv, db, editStore, recordStore, dcRecordStore, compStore, authStore, formTxr, tocTxr, orderTxr, xmlp, assignDataIdFlow, indexNewRecordFlow, compRecordFlow, ppFlow, sourceDir, baseDocFac
    #Discover objects
    session = Session()
    session.database = 'db_ead'
    session.environment = 'apache'
    session.user = None
    serv = SimpleServer(session, '/home/cheshire/cheshire3/cheshire3/configs/serverConfig.xml')
    db = serv.get_object(session, 'db_ead')
    baseDocFac = db.get_object(session, 'baseDocumentFactory')
    sourceDir = baseDocFac.get_default(session, 'data')
    editStore = db.get_object(session, 'editingStore')
    recordStore = db.get_object(session, 'recordStore')
    dcRecordStore = db.get_object(session, 'eadDcStore')
    compStore = db.get_object(session, 'componentStore')
    authStore = db.get_object(session, 'eadAuthStore')
    assignDataIdFlow = db.get_object(session, 'assignDataIdentifierWorkflow')
    compRecordFlow = db.get_object(session, 'buildComponentWorkflow')
    indexNewRecordFlow = db.get_object(session, 'indexNewRecordWorkflow')
    ppFlow = db.get_object(session, 'preParserWorkflow')
    # transformers
    xmlp = db.get_object(session, 'LxmlParser')
    formTxr = db.get_object(session, 'formCreationTxr')
    tocTxr = db.get_object(session, 'editingTocTxr')
    orderTxr = db.get_object(session, 'orderingTxr')
    rebuild = False



def handler(req):

    global rebuild, logfilepath, cheshirePath, db, editStore, xmlp, formTxr, tocTxr, script                # get the remote host's IP
    script = req.subprocess_env['SCRIPT_NAME']
    req.register_cleanup(build_architecture)

    try :

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
            del lgr, eadEditingHandler                                          # handle request
    except:
        req.content_type = "text/html"
        cgitb.Hook(file = req).handle()                                         # give error info
    else :
        return apache.OK


def authenhandler(req):
    global session, authStore, rebuild
    if (rebuild):
        build_architecture()                                                    # build the architecture
    pw = req.get_basic_auth_pw()
    un = req.user
    try: session.user = authStore.fetch_object(session, un)
    except: return apache.HTTP_UNAUTHORIZED    
    if (session.user and session.user.password == crypt(pw, pw[:2])):
        return apache.OK
    else:
        return apache.HTTP_UNAUTHORIZED
#- end authenhandler()


#- end handler()