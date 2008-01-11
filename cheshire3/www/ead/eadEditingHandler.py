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




from eadHandler import *
from copy import deepcopy

# script specific globals
#script = '/ead/edit/'

class EadEditingHandler(EadHandler):
    global repository_name, repository_link, repository_logo, htmlPath
    templatePath = os.path.join(htmlPath, 'template.ssi')

    htmlTitle = None
    htmlNav = None
    logger = None
    errorFields = []
    
    altrenderDict = { 'surname' : 'a',
                      'dates' : 'y',
                      'other' : 'x',
                      'loc' : 'z'                    
                     }

    def __init__(self, lgr):
        EadHandler.__init__(self, lgr)
        self.htmlTitle = ['Data Creation and Editing']
        self.htmlNav = ['<a href="javascript: toggleKeyboard();">Show Character Keyboard</a>']
        self.logger = lgr

    #- end __init__


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

    # end _validate_isadg()
    
    
    def preview_file(self, req):
        global session, repository_name, repository_link, repository_logo, cache_path, cache_url, toc_cache_path, toc_cache_url, toc_scripts, script, fullTxr, fullSplitTxr
        form = FieldStorage(req)
        self.htmlTitle.append('Preview File')
        self.htmlNav.append('<a href="/ead/admin/files.html" title="Preview File" class="navlink">Files</a>')
#        f = form.get('eadfile', None)
        pagenum = int(form.getfirst('pagenum', 1))
        
        self.logger.log('Preview requested')
#        rec = self._parse_upload(f.value)
        recid=form.get('recid', None)
        if recid != None and recid != 'null' :
            rec = editStore.fetch_record(session, recid)
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
            page = page
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
    #- end preview_file()

    
    def send_xml(self, data, req, code=200):
        req.content_type = 'text/xml'
        req.content_length = len(data)
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()       
    #- end send_xml()
    
    
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
            self._add_text(target, '%s %s %s' % (form.get('did/unitid/@countrycode', ''), form.get('did/unitid/@mainagencycode', ''), form.get('did/unitid', '')))
            target = self._create_path(header, 'eadid/@countrycode')
            self._add_text(target, form.get('did/unitid/@countrycode', ''))
            target = self._create_path(header, 'eadid/@mainagencycode')
            self._add_text(target, form.get('did/unitid/@mainagencycode', ''))
            target = self._create_path(header, 'titlestmt/titleproper')
            self._add_text(target, form.get('did/unittitle', ''))            
        else :
            tree = etree.fromstring('<%s id="%s"></%s>' % (ctype, level, ctype))           
        list = form.list     
        for field in list :
            if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent']:              
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
            
                        
    def _append_element(self, parentNode, childNode):    
        parentNode.append(childNode)
        return childNode

    
    def _add_attribute(self, parentNode, attribute):
        parentNode.attrib[attribute] = ""
        return [parentNode, attribute]
 
        
    def _add_text(self, parent, textValue):
        if not (textValue.find('&') == -1):
            textValue = textValue.replace('&', '&#38;')
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

       
    def _delete_currentControlaccess(self, startNode, list=['subject','persname', 'famname', 'corpname', 'geogname', 'title']):
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
                    if (field[1] != 'none') :
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
   
       
    def populate_form(self, recid, new):  
        #if its collection level give the transformer the whole record
        if (new == 'collectionLevel'):  
            retrievedDom = editStore.fetch_record(session, recid).get_dom(session)
            rec = LxmlRecord(retrievedDom)
        #if its a component find the component by id and just give that component to the transformer          
        else :
            retrievedXml = editStore.fetch_record(session, recid).get_xml(session)
            root = None
            tree = etree.XMLID(retrievedXml)
            self.logger.log(tree[0])
            self.logger.log(tree[1])
            node = tree[1].get(new)
            for e in tree[0].getiterator() :
                if e == node :
                    root = deepcopy(e)
            rec = LxmlRecord(root)          
        page = formTxr.process_record(session, rec).get_raw(session)
        return page.replace('%RECID%', '')

    
    def save_form(self, form):
        loc = form.get('location', None)
        self.logger.log('location = %s' % loc)
        recid = form.get('recid', None)
        self.logger.log('recid = %s' % recid)
        parent = form.get('parent', None)
        if (loc == 'collectionLevel' and (recid == None or recid == 'None')):
            self.logger.log('new collection level')
            #save the form in any free slot
            rec = LxmlRecord(self.build_ead(form))
            rec = assignDataIdFlow.process(session, rec)
            recid = rec.id
            editStore.store_record(session, rec)
            editStore.commit_storing(session) 
            return recid
        elif (loc == 'collectionLevel'):
            list = form.list  
            #pull existing xml and make into a tree
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedXml = retrievedRec.get_xml(session)
            tree = etree.fromstring(retrievedXml)
            node = tree.xpath('/ead/archdesc')[0]         
            #first delete current accesspoints
            self._delete_currentControlaccess(node)
            self._delete_currentLangusage(node)
            #change title in header
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header, 'titlestmt/titleproper')
            self._add_text(target, form.get('did/unittitle', ''))
            #cycle through the form and replace any node that need it
            for field in list :                
                if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent']:                   
                    #do archdesc stuff
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
        #check if C exists, if not add it, if so replace it
        else :
            self.logger.log('component')
            self.logger.log('loc is %s' % loc)
            #pull record from store            
            retrievedRec = editStore.fetch_record(session, recid)
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
                self.logger.log('=====================================================')
                self.logger.log(list)
                self.logger.log('=====================================================')
                node = tree[1].get(loc) 
                self.logger.log(node)
                #first delete current accesspoints
                self._delete_currentControlaccess(node)
                for field in list :
                    if field.name not in ['ctype','location','operation','newForm','nocache','recid', 'parent']:            
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
                rec = LxmlRecord(tree[0])
                rec.id = retrievedRec.id
                editStore.store_record(session, rec)
                editStore.commit_storing(session)
            return recid    
    
    
    def _add_componentIds (self, rec):
        tree = etree.fromstring(rec.get_xml(session))
        compre = re.compile('c[0-9]*$')
        for element in tree.getiterator():
            try :
                if compre.match(element.tag):
                    if not element.get('id'):
                        #add the appropriate id!
                        posCount = 1
                        parentId = ''
                        for el in element.itersiblings(preceding=True):
                            if compre.match(el.tag):
                                posCount += 1
                        #get the parent component' id and use it 
                        for el in element.iterancestors():
                            if compre.match(el.tag):
                                parentId = el.get('id')
                                parentId = parentId[parentId.find('-')+1:]
                                if parentId[-1] == '-':
                                    parentId = parentId[:-1]                                
                                break
                        idString = 'C%d-%d-%s' % (self._get_depth(element), posCount, parentId)
                        if idString[-1] == '-':
                            idString = idString[:-1]
                        element.set('id', idString)                               
            except :
                continue
        return LxmlRecord(tree)
                    
                
    def _get_depth (self, node):
        compre = re.compile('c[0-9]*$')
        depth = 0;
        for element in node.iterancestors():
            if compre.match(element.tag) or element.tag == 'archdesc':
                depth += 1
        return depth                
    
    
    def edit_file(self, form):
        f = form.get('filepath', None)
        if not f or not len(f.value):
            #create appropriate html file - this is for admin
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
        recid = rec.id

        editStore.store_record(session, rec)
        editStore.commit_storing(session) 
        structure = read_file('ead2002.html') 
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        page = structure.replace('%FRM%', htmlform) 
        page = page.replace('%RECID%', '<input type="hidden" id="recid" value="%s"/>' % recid)
        page = page.replace('%TOC%', tocTxr.process_record(session, rec).get_raw(session))
        return page
           

    def add_form(self, form):
        recid = form.get('recid', None)
        doc = StringDocument('<c><recid>%s</recid></c>' % recid)
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        return htmlform


    def navigate(self, form):    
        recid = form.get('recid', None)
        new = form.get('newForm', None)
        page = self.populate_form(recid, new)    
        return page 
         
         
    def generate_form(self, req):
        structure = read_file('ead2002.html')
        #doc = StringDocument(editStore.fetch_record(session, 'david').get_xml(session))
        doc = StringDocument('<ead><eadheader></eadheader><archdesc></archdesc></ead>')         
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        page = structure.replace('%FRM%', htmlform) 
        page = page.replace('%RECID%', '')
        return page
    
    
    def display(self, req):
        form = FieldStorage(req)
        recid=form.get('recid', None)
        if recid != None and recid != 'null' :
            retrievedRec = editStore.fetch_record(session, recid)
            retrievedxml= retrievedRec.get_xml(session)
            tree = etree.fromstring(retrievedxml)
            return etree.tostring(tree)
        else :
            return '<p>Unable to display xml</p>'
    
       
    def checkId(self, req):
        form = FieldStorage(req)
        id = form.get('id', None)
        if (id != None):
            if (id in recordStore.fetch_idList(session)):
                return '<value>true</value>'    
            else :
                return '<value>false</value>'
    
    
    def _get_timeStamp(self):
        return time.strftime('%Y-%m-%dT%H%M%S')
    
    
    def submit(self, form):
        global sourceDir
        recid = self.save_form(form)
        rec = editStore.fetch_record(session, recid)
        xml = rec.get_xml(session)        
        newname = '%s-%s-%s.xml' % (recid, session.user.username, self._get_timeStamp())
        write_file(os.path.join(sourceDir, newname), xml)
        req.write('File uploaded and stored on server as <code>%s</code><br/>\n' % (newname))
        # 'open' all dbs and recordStores
        db.begin_indexing(session)
        recordStore.begin_storing(session)
        dcRecordStore.begin_storing(session)
        req.write('Loading and Indexing record .')
        indexRecordFlow.process(session, rec)
        recordStore.commit_storing(session)
        dcRecordStore.commit_storing(session)
        if len(rec.process_xpath('dsc')):
            req.write('Loading and Indexing components .')
            compStore.begin_storing(session)
            # extract and index components
            compRecordFlow.process(session, rec)
            compStore.commit_storing(session)
            
        req.write('Merging indexes ...')
        try:
            db.commit_indexing(session)
            db.commit_metadata(session)
        except:
            req.write('<span class="error">[ERROR]</span> - Could not finish merging indexes. Your record may not be available to search.<br/>\n')
        else:
            req.write('<span class="ok">[OK]</span><br/>\nUPLOAD + INDEXING COMPLETE')
        
        return '<p>Process Complete</p>' 
    
    
    def validate(self, req):
        form = FieldStorage(req)
        text = form.get('text', None)
        if not text.find('<') == -1:
            try :
                test = etree.fromstring('<foo>%s</foo>' % text)
                return '<value>true</value>'
            except :
                return '<value>false</value>'
        else :
            return '<value>true</value>'
                
                
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
                content = self.checkId(req)
                self.send_xml(content, req)
            elif (operation == 'validate'):
                content = self.validate(req)
                self.send_xml(content, req)               
            elif (operation == 'submit'):
                content = self.submit(form)
                tmpl = read_file(self.templatePath)                                        # read the template in
                page = tmpl.replace("%CONTENT%", content)
        
                self.globalReplacements.update({
                    "%TITLE%": ' :: '.join(self.htmlTitle)
                   ,"%NAVBAR%": ' | '.join(self.htmlNav),
                   })
        
                page = multiReplace(page, self.globalReplacements)
                self.send_html(page, req)   
            elif (operation == 'edit'):
                
                content = self.edit_file(form)
                tmpl = read_file(self.templatePath)                                        # read the template in
                page = tmpl.replace("%CONTENT%", content)
        
                self.globalReplacements.update({
                    "%TITLE%": ' :: '.join(self.htmlTitle)
                   ,"%NAVBAR%": ' | '.join(self.htmlNav),
                   })
        
                page = multiReplace(page, self.globalReplacements)
                self.send_html(page, req) 
  
            
        else :    
                   
            content = self.generate_form(req)
           
            tmpl = read_file(self.templatePath)                                        # read the template in
            page = tmpl.replace("%CONTENT%", content)
    
            self.globalReplacements.update({
                "%TITLE%": ' :: '.join(self.htmlTitle)
               ,"%NAVBAR%": ' | '.join(self.htmlNav),
               })
    
            page = multiReplace(page, self.globalReplacements)
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
indexRecordFlow = None
xmlp = None
formTxr = None
tocTxr = None
logfilepath = editinglogfilepath

def build_architecture(data=None):
    global session, serv, db, editStore, recordStore, dcRecordStore, compStore, authStore, formTxr, tocTxr, xmlp, assignDataIdFlow, indexRecordFlow, compRecordFlow, sourceDir, baseDocFac
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
    indexRecordFlow = db.get_object(session, 'indexRecordWorkflow')
    compRecordFlow = db.get_object(session, 'buildComponentWorkflow')
    # transformers
    xmlp = db.get_object(session, 'LxmlParser')
    formTxr = db.get_object(session, 'formCreationTxr')
    tocTxr = db.get_object(session, 'editingTocTxr')
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