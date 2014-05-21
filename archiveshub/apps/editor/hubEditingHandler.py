#
# Script:    hubEditingHandler.py
# Version:   0.07
# Date:      25 January 2013
# Copyright: &copy; University of Liverpool 2013
# Description:
#            Data creation and editing interface for EAD finding aids
#            - part of Cheshire for Archives v3
#
# Author(s): CS - Catherine Smith <catherine.smith@liverpool.ac.uk>
#            JH - John Harrison <john.harrison@liv.ac.uk>
#
# Language:  Python
# Required externals:
#            cheshire3-base, cheshire3-sql, cheshire3-web
#
# Version History: # left as example
# 0.01 - 20/01/2009 - CS - All functions for first release
# 0.02 - 21/10/2010 - JH - New branding applied
#                        - Minor bug fixes
# 0.03 - 02/06/2011 - JH - Prevent reassign of builtin function 'list'
# 0.04 - 07/06/2011 - JH - Prevent cgitb module from hiding server errors from
#                          AJAX
#                        - Bug fix for punctuation array single-item tuples
#                          (foo,) rather than (foo)
# 0.05 - 17/11/2011 - JH - Sort users alphabetically, case insensitive,
#                          regardless of underlying dbms (SQL)
# 0.06 - 07/06/2012 - JH - Add username in response when saving record
#                        - Fix bug when adding type="persistent"
#                        - Prevent duplication in list of user records
# 0.07 - 25/01/2013 - JH - Fixed validation of record in record tree
# 
#        24/04/2014 - JH - Version history superceded by version control

import sys
import os
import urllib
import time
import smtplib
import re
import cgitb
import traceback
#import cProfile
import codecs
import datetime
import glob

from pprint import pformat
from copy import deepcopy
from crypt import crypt
from email import Message, MIMEMultipart, MIMEText  # email modules
from lxml import etree  # Lxml tree manipulation

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

# import mod_python stuffs
from mod_python import apache, Cookie
from mod_python.util import FieldStorage, redirect

# import customisable variables
from hubeditLocalConfig import *

# Cheshire3 stuff
from cheshire3.baseObjects import Session, Record, ResultSet


from cheshire3.document import StringDocument
from cheshire3.exceptions import ObjectDoesNotExistException, XMLSyntaxError
from cheshire3.internal import cheshire3Root
from cheshire3.record import LxmlRecord
from cheshire3.server import SimpleServer
from cheshire3.utils import flattenTexts

from cheshire3.web.www_utils import html_encode, read_file, multiReplace
from cheshire3.web.www_utils import *


DUMMY_EAD = '<ead><eadheader></eadheader><archdesc></archdesc></ead>'


class HubEditingHandler(object):
    global repository_name, repository_link, repository_logo, htmlPath
    templatePath = os.path.join(htmlPath, 'template.html')
    recordTemplatePath = os.path.join(htmlPath, 'template-record.html')
    logger = None
    errorFields = []
    required_xpaths_components = ['did/unitid',
                                  'did/unittitle',
                                  'did/unitdate',
                                  'did/unitdate/@normal']
    required_xpaths = ['did/unitid',
                       'did/unittitle',
                       'did/unitdate',
                       'did/unitdate/@normal',
                       'did/repository',
                       'did/origination',
                       'did/physdesc/extent',
                       'did/langmaterial/language',
                       'scopecontent',
                       'accessrestrict']

    altrenderDict = {'surname': 'a',
                     'organisation': 'a',
                     'dates': 'y',
                     'other': 'x',
                     'loc': 'z'
                     }

    # Dictionaries of punctuation
    # One string means that it goes after the values two strings are either
    # side first before second after
    persnamePunct = {'a': (u',\u00A0',),
                     'forename': (u'.\u00A0',),
                     'y': (u'(', u')\u00A0'),
                     'epithet': (u',\u00A0',)
                     }

    famnamePunct = {'a': (u'\u00A0family.\u00A0',),
                    'x': (u'.\u00A0',),
                    'title': (u'.\u00A0',),
                    'y': (u'(', u')\u00A0'),
                    'z': (u'.\u00A0',)
                    }

    corpnamePunct = {'x': (u'\u00A0--\u00A0', u'\u00A0'),
                     'y': (u'(', u')\u00A0'),
                     'z': (u'\u00A0--\u00A0', u'\u00A0')
                     }

    subjectPunct = {'x': (u'\u00A0--\u00A0', u'\u00A0'),
                    'y': (u'\u00A0--\u00A0', u'\u00A0'),
                    'z': (u'\u00A0--\u00A0', u'\u00A0')
                    }

    geognamePunct = {'x': (u'\u00A0--\u00A0', u'\u00A0'),
                     'y': (u'\u00A0--\u00A0', u'\u00A0'),
                     'z': (u'\u00A0--\u00A0', u'\u00A0')
                     }

    typeDict = {'persname': persnamePunct,
                'famname': famnamePunct,
                'corpname': corpnamePunct,
                'subject': subjectPunct,
                'geogname': geognamePunct}

    def __init__(self, lgr=None, myscript=None):

        if myscript is not None:
            self.script = myscript
        else:
            self.script = script

        self.globalReplacements = {'%PAGECLASS%': '',
                                   '%REP_NAME%': repository_name,
                                   '%REP_LINK%': repository_link,
                                   '%REP_LOGO%': repository_logo,
                                   'SCRIPT': self.script,
                                   '%SCRIPT%': self.script,
                                   '<br>': '<br/>',
                                   '<hr>': '<hr/>'
                                   }

    def _get_timeStamp(self):
        return time.strftime('%Y-%m-%dT%H%M%S')

    def _get_userInstitutionId(self, username):
        # Return the institution id of the user performing the operation
        global authStore
        sqlQ = ("SELECT institutionid "
                "FROM eadAuthStore_linkauthinst "
                "WHERE eadAuthStore=%s")
        res = authStore._query(sqlQ, (username,))
        if len(res) > 1:
            # We have two templates with the same id - should never happen
            return None
        else:
            return res[0][0]

    def send_response(self, data, req, content_type=None, code=200):
        if content_type is not None:
            req.content_type = content_type
        # Attempt to disable all HTML caching
        req.headers_out['cache-control'] = "no-cache"
        req.headers_out['expires'] = time.strftime("%a, %d %b %Y %H:%M:%S %Z",
                                                   time.gmtime(0)
                                                   )
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()

    def send_html(self, data, req, code=200):
        self.send_response(data, req, 'text/html; charset=utf-8', code)

    def send_xml(self, data, req, code=200):
        self.send_response(data, req, 'application/xml', code)

    def send_fullHtml(self, data, req, code=200):
        # read the template in
        tmpl = read_file(self.templatePath)
        page = tmpl.replace("%CONTENT%", data)
        self.globalReplacements.update({
            "%TITLE%": ' :: '.join(self.htmlTitle),
            "%NAVBAR%": ' '.join(self.htmlNav),
        })
        page = multiReplace(page, self.globalReplacements)
        req.content_type = 'text/html'
        req.headers_out['Cache-Control'] = "no-cache, no-store"
        req.send_http_header()
        if (type(page) == unicode):
            page = page.encode('utf-8')
        req.write(page)
        req.flush()

    def _validate_isadg(self, rec):
        required_xpaths = ['/ead/eadheader/eadid']
        # check record for presence of mandatory XPaths
        missing_xpaths = []
        for xp in required_xpaths:
            try:
                rec.process_xpath(session, xp)[0]
            except IndexError:
                missing_xpaths.append(xp)
        if len(missing_xpaths):
            self.htmlTitle.append('Error')
            newlineRe = re.compile('(\s\s+)')
            return '''
    <p class="error">Your file does not contain the following mandatory
    XPath(s):<br/>
    {0}
    </p>
    <pre>
    {1}
    </pre>
    '''.format('<br/>'.join(missing_xpaths),
               newlineRe.sub('\n\g<1>', html_encode(rec.get_xml(session)))
               )
        else:
            return None
        # end _validate_isadg() ---------------------------------------------

    # EAD Creation and Editing Functions ====================================

    def build_ead(self, form, template=False):
        self.log('building ead')
        # Get the template stuff out of the way if this is a template
        if template is True:
            name = form.get('/template/@name', None)
            tree = etree.fromstring('<template name="{0}"><ead>'
                                    '<eadheader></eadheader>'
                                    '<archdesc></archdesc></ead>'
                                    '</template>'.format(name)
                                    )
            header = tree.xpath('/template/ead/eadheader')[0]
            target = self._create_path(header,
                                       'filedesc/titlestmt/titleproper'
                                       )
            self._add_text(target, form.get('did/unittitle', ''))
            if form.get('filedesc/titlestmt/sponsor', '') != '':
                target = self._create_path(header,
                                           'filedesc/titlestmt/sponsor'
                                           )
                self._add_text(target,
                               form.get('filedesc/titlestmt/sponsor', '')
                               )
            mylist = form.list
            daonames = {}
            node = tree.xpath('/template/ead/archdesc')[0]
            for field in mylist:
                if (
                    field.name not in ['ctype', 'location', 'operation',
                                       'newForm', 'owner', 'recid', 'parent',
                                       'pui', 'eadid',
                                       'filedesc/titlestmt/sponsor',
                                       'daoselect', 'tempid']
                ):
                    # do did level stuff
                    if field.name.find('controlaccess') == 0:
                        self._create_controlaccess(node,
                                                   field.name,
                                                   field.value
                                                   )
                        try:
                            validList.remove('controlaccess')
                        except:
                            pass
                    elif field.name.find('did/langmaterial') == 0:
                        did = self._create_path(node, 'did')
                        self._create_langmaterial(did, field.value)
                        try:
                            validList.remove('did/langmaterial/language')
                        except:
                            pass
                    elif field.name.find('dao') == 0:
                        daoname = field.name.split('|')
                        try:
                            daodict = daonames[daoname[0]]
                        except:
                            daodict = {}
                        fieldval = field.value.strip()
                        if (
                            fieldval not in ['', ' ', '<p></p>'] and
                            re.sub('[\s]+', ' ', fieldval) != '<p> </p>'
                        ):
                            daodict[daoname[1]] = field.value

                        daonames[daoname[0]] = daodict
                    else:
                        fieldval = field.value.strip()
                        if (
                            fieldval not in ['', ' ', '<p></p>'] and
                            re.sub('[\s]+', ' ', fieldval) != '<p> </p>'
                        ):

                            target = self._create_path(node, field.name)
                            self._add_text(target, field.value)
                            try:
                                validList.remove(
                                    field.name[:field.name.rfind('[')]
                                )
                            except:
                                try:
                                    validList.remove(field.name)
                                except:
                                    pass
            self._create_dao(daonames, node)
            self.log('build complete')
            return (tree, name)

        # Deal with real EAD (not templates)
        ctype = form.get('ctype', None)
        loc = form.get('location', None)
        collection = False
        validList = None
        if (loc == 'collectionLevel'):
            validList = [l for l in self.required_xpaths]
            collection = True
            # Set all the ead header info
            tree = etree.fromstring(DUMMY_EAD)
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header, 'eadid')
            eadidStr = form.get('eadid', form.get('pui', 'noid'))
            self.log(eadidStr)
            if eadidStr:
                self._add_text(target, eadidStr)

            target = self._create_path(header, 'eadid/@countrycode')
            ccStr = form.get('did/unitid/@countrycode',
                             form.get('did/unitid[1]/@countrycode', '')
                             )
            self._add_text(target, ccStr)
            target = self._create_path(header, 'eadid/@mainagencycode')
            macStr = form.get('did/unitid/@repositorycode',
                              form.get('did/unitid[1]/@repositorycode', '')
                              )
            self._add_text(target, macStr)
            target = self._create_path(header, 'eadid/@identifier')
            identAttr = form.get("did/unitid",
                                 form.get("did/unitid[1]", '')
                                 )
            identAttr = identAttr.replace(" ", "")
            if identAttr.startswith(ccStr + macStr):
                identAttr = identAttr[len(ccStr + macStr):].lstrip(' -')

            self._add_text(target, identAttr)
            target = self._create_path(header,
                                       'filedesc/titlestmt/titleproper'
                                       )
            self._add_text(target, form.get('did/unittitle', ''))
            if form.get('filedesc/titlestmt/sponsor', '') != '':
                target = self._create_path(header,
                                           'filedesc/titlestmt/sponsor'
                                           )
                self._add_text(target,
                               form.get('filedesc/titlestmt/sponsor', '')
                               )
            target = self._create_path(header, 'profiledesc/creation')
            if session.user.realName != '':
                userName = session.user.realName
            else:
                userName = session.user.username
            self._add_text(target,
                           'Created by {0} using the Archives Hub EAD Editor'
                           ''.format(userName)
                           )
            target = self._create_path(header, 'profiledesc/creation/date')
            self._add_text(target, datetime.date.today().isoformat())
        else:
            validList = [l for l in self.required_xpaths_components]
            tree = etree.fromstring('<{0} c3id="{1}"></{0}>'.format(ctype,
                                                                    loc))
        # Build the rest of the ead
        mylist = form.list
        daonames = {}
        if (collection):
            node = tree.xpath('/ead/archdesc')[0]
            valid = self._updateNodeFromFieldList(node, mylist)
        else:
            node = tree.xpath('/*[not(name() = "ead")]')[0]
            valid = self._updateNodeFromFieldList(node,
                                                  mylist,
                                                  component=True
                                                  )

        self.log('build complete')
        return (tree, valid)
    #- end build_ead

    def _create_dao(self, dao_dict, node):
        if node.xpath('did'):
            startnode = node.xpath('did')[0]
        else:
            startnode = self._create_path(node, 'did')
        for k in sorted(dao_dict):
            dao = dao_dict[k]
            keys = dao.keys()
            if 'new' in keys:
                if 'href' in keys:
                    daoelem = etree.Element('dao')
                    daoelem.attrib['href'] = dao['href']
                    daoelem.attrib['show'] = dao['new']
                    if 'desc' in keys:
                        descelem = etree.Element('daodesc')
                        self._add_text(descelem, dao['desc'])
                        daoelem.append(descelem)
                    startnode.append(daoelem)
            elif 'embed' in keys:
                if 'href' in keys:
                    daoelem = etree.Element('dao')
                    daoelem.attrib['href'] = dao['href']
                    daoelem.attrib['show'] = dao['embed']
                    if 'desc' in keys:
                        descelem = etree.Element('daodesc')
                        self._add_text(descelem, dao['desc'])
                        daoelem.append(descelem)
                    startnode.append(daoelem)
            elif 'thumb' in keys:
                if 'href1' in keys and 'href2' in keys:
                    daoelem = etree.Element('daogrp')
                    startnode.append(daoelem)

                    daoloc = etree.Element('daoloc')
                    daoloc.attrib['href'] = dao['href1']
                    daoloc.attrib['role'] = dao['thumb']
                    daoelem.append(daoloc)
                    daoloc = etree.Element('daoloc')
                    daoloc.attrib['href'] = dao['href2']
                    daoloc.attrib['role'] = dao['reference']
                    daoelem.append(daoloc)
                    if 'desc' in keys:
                        descelem = etree.Element('daodesc')
                        self._add_text(descelem, dao['desc'])
                        daoelem.append(descelem)

            else:
                hrefpresent = False
                hrefs = []
                for key in keys:
                    if key.find('href') == 0:
                        hrefs.append(key)
                if len(hrefs) > 0:
                    daoelem = etree.Element('daogrp')
                    startnode.append(daoelem)
                    for i in range(1, len(hrefs) + 1):
                        daoloc = etree.Element('daoloc')
                        daoloc.attrib['href'] = dao['href%d' % i]
                        daoloc.attrib['role'] = dao['role%d' % i]
                        if 'title%d' % i in keys:
                            daoloc.attrib['title'] = dao['title%d' % i]
                        daoelem.append(daoloc)
                    if 'desc' in keys:
                        descelem = etree.Element('daodesc')
                        self._add_text(descelem, dao['desc'])
                        daoelem.append(descelem)

    def _delete_path(self, startNode, nodePath):
        if not (startNode.xpath(nodePath)):
            return
        else:
            if nodePath.find('@') > -1:
                string = nodePath[nodePath.rfind('@') + 1:]
                if nodePath.find('/') == -1:
                    parent = startNode
                else:
                    parent = startNode.xpath(
                        ''.join(nodePath[:nodePath.rfind('/')])
                    )[0]
                try:
                    del parent.attrib[string]
                except KeyError:
                    pass
            else:
                child = startNode.xpath(nodePath)[0]
                if child.tag == 'dao':
                    if child.get('href') is not None:
                        return
                if nodePath.find('/') == -1:
                    parent = startNode
                else:
                    parent = startNode.xpath(
                        ''.join(nodePath[:nodePath.rfind('/')])
                    )[0]
                parent.remove(child)
            if len(parent.getchildren()) > 0 or parent.text is not None:
                return
            else:
                return self._delete_path(startNode,
                                         nodePath[:nodePath.rfind('/')]
                                         )

    def _create_path(self, startNode, nodePath):
        if (startNode.xpath(nodePath)):
            # Element/Attribute already exists in document
            if '@' in nodePath:
                # It's an attribute
                if len(startNode.xpath(nodePath[:nodePath.rfind('/')])) > 0:
                    # An attribute of a sub-element
                    parent = startNode.xpath(
                        nodePath[:nodePath.rfind('/')]
                    )[0]
                else:
                    parent = startNode
                attribute = nodePath[nodePath.rfind('@') + 1:]
                return [parent, attribute]
            else:
                return startNode.xpath(nodePath)[0]
        elif nodePath.startswith('@'):
            # Create and return an attribute
            return self._add_attribute(startNode, nodePath[1:])
        elif '/' not in nodePath:
            # A direct descendent of startNode
            if '[' in nodePath:
                # Contains predicate
                newNode = etree.Element(nodePath[:nodePath.find('[')])
            else:
                newNode = etree.Element(nodePath)
            return self._append_element(startNode, newNode)
        else:
            # Not a direct descendent of startNode
            # Recurse to create all intermediate elements
            newNodePath = ''.join(nodePath[:nodePath.rfind('/')])
            nodeString = ''.join(nodePath[nodePath.rfind('/') + 1:])
            if not nodeString.startswith('@'):
                if nodeString.find('[') != -1:
                    newNode = etree.Element(nodeString[:nodeString.find('[')])
                else:
                    newNode = etree.Element(nodeString)
                return self._append_element(
                    self._create_path(startNode, newNodePath),
                    newNode
                )
            else:
                # Simple attribute
                return self._add_attribute(
                    self._create_path(startNode, newNodePath),
                    nodeString[1:]
                )

    def _append_element(self, parentNode, childNode):
        parentNode.append(childNode)
        return childNode

    def _add_attribute(self, parentNode, attribute):
        parentNode.attrib[attribute] = ""
        return [parentNode, attribute]

    def _delete_currentControlaccess(
        self,
        startNode,
        mylist=['subject',
                'persname',
                'famname',
                'corpname',
                'geogname',
                'title',
                'genreform',
                'function'
                ]
    ):
        if (startNode.xpath('controlaccess')):
            parent = startNode.xpath('controlaccess')[0]
            for s in mylist:
                if (parent.xpath('%s' % s)):
                    child = parent.xpath('%s' % s)
                    for c in child:
                        parent.remove(c)
            if len(parent.getchildren()) == 0:
                startNode.remove(parent)

    def _delete_currentLangmaterial(self, startNode):
        try:
            did = startNode.xpath('did')[0]
        except IndexError:
            # no <did> to delete langmaterialf from
            return
        if (did.xpath('langmaterial')):
            parent = did.xpath('langmaterial')[0]
            child = parent.xpath('language')
            if len(child) > 0:
                for c in child:
                    parent.remove(c)
            did.remove(parent)

    def _delete_currentDao(self, startNode):
        # Delete dao from outside did
        children = startNode.xpath('dao')
        if len(children) > 0:
            for c in children:
                startNode.remove(c)
        # Delete daogrp from outside did
        children = startNode.xpath('daogrp')
        if len(children) > 0:
            for c in children:
                startNode.remove(c)
        try:
            did = startNode.xpath('did')[0]
        except IndexError:
            return
        # Delete dao from inside did
        children = did.xpath('dao')
        if len(children) > 0:
            for c in children:
                did.remove(c)
        # Delete daogrp from inside did
        children = did.xpath('daogrp')
        if len(children) > 0:
            for c in children:
                did.remove(c)

    def _create_langmaterial(self, startNode, value, name=None):
        if not (startNode.xpath('langmaterial')):
            langmaterial = etree.Element('langmaterial')
            startNode.append(langmaterial)
            lmNode = langmaterial
        else:
            lmNode = startNode.xpath('langmaterial')[0]
        fields = value.split(' ||| ')
        language = etree.SubElement(lmNode,
                                    'language',
                                    langcode='%s' % fields[0].split(' | ')[1]
                                    )
        text = fields[1].split(' | ')[1]
        self._add_text(language, text)

    def _add_text(self, parent, textValue):
        if not (textValue.find('&amp;') == -1):
            textValue = textValue.replace('&amp;', '&#38;')
        else:
            if not (textValue.find('&') == -1):
                regex = re.compile('&(?!#[0-9]+;)')
                textValue = regex.sub('&#38;', textValue)
        textValue = textValue.lstrip()
        if isinstance(parent, etree._Element):
            for c in parent.getchildren():
                parent.remove(c)
            value = '<foo>%s</foo>' % textValue
            try:
                nodetree = etree.fromstring(value)
            except:
                self.errorFields.append(parent.tag)
                parent.text = textValue
            else:
                parent.text = nodetree.text
                for n in nodetree:
                    parent.append(n)
        else:
            parent[0].attrib[parent[1]] = textValue

    def _create_controlaccess(self, startNode, name, value):
        # get the controlaccess node or create it
        try:
            caNode = startNode.xpath('controlaccess')[0]
        except IndexError:
            caNode = etree.Element('controlaccess')
            startNode.append(caNode)
        typeString = name[name.find('/') + 1:]
        type_ = etree.Element(typeString)
        caNode.append(type_)
        fields = value.split(' ||| ')
        for i, f in enumerate(fields):
            if not (f == ''):
                field = f.split(' | ')
                typelabel = field[0].split('_')[0]
                fieldlabel = field[0].split('_')[1]
                if (
                    fieldlabel == 'source' or
                    fieldlabel == 'rules' or
                    typelabel == 'att'
                ):
                    if (field[1] != 'none'):
                        type_.set(fieldlabel, field[1].lower())
                else:
                    punctList = self.typeDict.get(typeString, {})
                    if fieldlabel == typelabel:
                        attributeValue = 'a'
                    else:
                        attributeValue = self.altrenderDict.get(fieldlabel,
                                                                fieldlabel)
                    emph = etree.Element('emph',
                                         altrender='%s' % attributeValue
                                         )
                    self._add_text(emph, field[1])
                    if i < len(fields):
                        punct = punctList.get(attributeValue, None)
                        if punctList and (punct is not None):
                            if len(punct) == 1:
                                emph.tail = punct[0]
                            else:
                                type_[-1].tail = ('{0}{1}'
                                                  ''.format(type_[-1].tail,
                                                            punct[0]
                                                            )
                                                  )
                                emph.tail = punct[1]
                        else:
                            emph.tail = ' '
                    type_.append(emph)
        lastTail = type_[-1].tail
        if re.match('(\s+)?[,\.\-](\s+)?', lastTail):
            type_[-1].tail = ''

    # Navigation related functions ==========================================

    def navigate(self, form):
        global session
        recid = form.get('recid', None)
        owner = form.get('owner', session.user.username)
        new = form.get('newForm', None)
        if self._hasPermission('%s-%s' % (recid, owner)):
            page = self.populate_form(recid, owner, new, form)
            return page
        else:
            return ('<p>'
                    'You do not have permission to perform the requested '
                    'operation on the requested record'
                    '</p>'
                    )

    def populate_form(self, recid, owner, new, form):
        global editStore, xmlp
        if (new == 'collectionLevel'):
            # Its collection level; give the transformer the whole record
            retrievedRecord = editStore.fetch_record(session,
                                                     '%s-%s' % (recid, owner)
                                                     )
            retrievedDom = retrievedRecord.get_dom(session)
            rec = LxmlRecord(retrievedDom)
        else:
            # It's a component; find the component by id and just give that
            # component to the transformer
            retrievedRecord = editStore.fetch_record(session,
                                                     '%s-%s' % (recid, owner)
                                                     )
            retrievedXml = retrievedRecord.get_xml(session)
            root = None
            tree = etree.fromstring(retrievedXml)
            comp = tree.xpath('//*[@c3id=\'%s\']' % new)
            try:
                root = comp[0]
            except:
                pass

            if root is None:
                ctype = form.get('ctype', 'c')
                doc = StringDocument('<{0}><recid>{1}</recid></{0}>'
                                     ''.format(ctype, recid)
                                     )
                rec = xmlp.process_document(session, doc)
            else:
                rec = LxmlRecord(root)

        pageDoc = formTxr.process_record(session, rec)
        page = pageDoc.get_raw(session)
        page = page.replace('%PUI%',
                            '<input type="text" onfocus="setCurrent(this);" '
                            'name="pui" id="pui" size="25" '
                            'disabled="disabled" value="{0}"/>'.format(recid)
                            )
        return page.replace('%RECID%', '')

    # Template creation/editing functions====================================

    def create_template(self, form):
        global xmlp
        self.log('CREATING NEW TEMPLATE')
        li = '<li class="navtab">{0}</li>'.format(keyboard_link)
        self.htmlNav[2] = li
        structure = read_file('eadtemplate.html')
        doc = StringDocument('<template>'
                             '<ead>'
                             '<eadheader></eadheader>'
                             '<archdesc></archdesc>'
                             '</ead>'
                             '</template>'
                             )
        rec = xmlp.process_document(session, doc)
        htmlform = formTxr.process_record(session, rec).get_raw(session)
        page = structure.replace('%FRM%', htmlform)
        page = page.replace('%RECID%', '')
        page = page.replace('%PUI%',
                            '<input type="hidden" name="pui" id="pui"/>'
                            )
        page = page.replace('%TOC%', '')
        page = page.replace('%MENUCODE%', read_file('contextMenu.html'))
        page = page.replace('%KYBDCODE%', read_file('keyboard.html'))
        return page

    def modify_template(self, form):
        self.log('MODIFYING TEMPLATE')
        templateName = form.get('templatesel2', None)
        if templateName is None:
            self.create_template(self, form)
        else:
            li = '<li class="navtab">{0}</li>'.format(keyboard_link)
            self.htmlNav[2] = li
            structure = read_file('eadtemplate.html')
            templateStore = db.get_object(session, 'templateStore')
            rec = templateStore.fetch_record(session, templateName)
            htmlform = formTxr.process_record(session, rec).get_raw(session)
            page = structure.replace('%FRM%', htmlform)
            page = page.replace('%RECID%', '')
            page = page.replace('%PUI%',
                                '<input type="hidden" name="pui" id="pui"/>'
                                )
            page = page.replace('%TOC%', '')
            page = page.replace('%MENUCODE%', read_file('contextMenu.html'))
            page = page.replace('%KYBDCODE%', read_file('keyboard.html'))
            return page

    def save_template(self, form):
        global xmlp, authStore, session
        self.log('SAVING TEMPLATE')
        templateStore = db.get_object(session, 'templateStore')
        templateStore.begin_storing(session)
        # Build template xml
        (templateXml, name) = self.build_ead(form, True)
        doc = StringDocument(etree.tostring(templateXml))
        rec = xmlp.process_document(session, doc)
        # Get the institution of the user performing the operation
        institutionid = self._get_userInstitutionId(session.user.username)
        rec.id = '%s-%s' % (name.strip(), institutionid)
        # Otherwise store in template store and create institution link
        templateStore.store_record(session, rec)
        templateStore.unlink(session,
                             'linktempinst',
                             rec,
                             institutionid=institutionid
                             )
        templateStore.link(session,
                           'linktempinst',
                           rec,
                           institutionid=institutionid
                           )
        templateStore.commit_storing(session)
        return '<name>%s</name>' % rec.id

    def discard_template(self, form):
        templateStore = db.get_object(session, 'templateStore')
        templateStore.begin_storing(session)
        recid = form.get('recid', None)
        institutionid = self._get_userInstitutionName(session.user.username)
        if not recid is None:
            try:
                templateStore.delete_record(session,
                                            '%s-%s' % (recid, institutionid)
                                            )
                templateStore.commit_storing(session)
                return 'done'
            except:
                return 'failed'
        else:
            return 'failed'

    # Loading in related functions ==========================================

    def _add_componentIds(self, rec):
        tree = etree.fromstring(rec.get_xml(session))
        compre = re.compile('^c[0-9]*$')
        for element in tree.iter(tag=etree.Element):
            if compre.match(element.tag):
                try:
                    # Add the appropriate id!
                    posCount = 1
                    parentId = ''
                    walker = element.itersiblings(tag=etree.Element,
                                                  preceding=True
                                                  )
                    for el in walker:
                        if compre.match(el.tag):
                            posCount += 1
                    # Get the parent component id and use it
                    for el in element.iterancestors():
                        if compre.match(el.tag):
                            parentId = el.get('c3id')
                            break
                    idString = '%s-%d' % (parentId, posCount)
                    if idString[0] == '-':
                        idString = idString[1:]
                    element.set('c3id', idString)
                except:
                    raise
        return LxmlRecord(tree)

    def generate_file(self, form):
        self.log('CREATING NEW FILE')
        # Check quota - fail if reached, alert somehow if close (within 10?)
        quota = self._get_quota()
        total = self._get_totalDrafts()

        if (quota - total) > 0:
            li = '<li class="navtab">{0}</li>'.format(keyboard_link)
            self.htmlNav[2] = li
            structure = read_file('ead2002.html')
            templateStore = db.get_object(session, 'templateStore')
            templateName = form.get('templatesel1', None)
            if templateName is None or templateName == 'blank':
                doc = StringDocument(DUMMY_EAD)
                rec = xmlp.process_document(session, doc)
            else:
                try:
                    tree = templateStore.fetch_record(
                        session,
                        templateName
                    ).get_dom(session)
                    newtree = tree.xpath('/template/ead')[0]
                    rec = xmlp.process_document(
                        session,
                        StringDocument(etree.tostring(newtree))
                    )
                except:
                    doc = StringDocument(DUMMY_EAD)
                    rec = xmlp.process_document(session, doc)
            htmlform = formTxr.process_record(session, rec).get_raw(session)
            page = structure.replace('%FRM%', htmlform)
            page = page.replace(
                '%RECID%',
                '<input type="hidden" id="recid" value="notSet"/>'
            )
            page = page.replace(
                '%PUI%',
                ('<input type="text" onfocus="setCurrent(this);" name="pui" '
                 'id="pui" size="25" readonly="true" class="readonly"/>'
                 )
            )
            page = page.replace(
                '%TOC%',
                ('<b><a id="collectionLevel" name="link" class="valid" '
                 'onclick="displayForm(this.id)" '
                 'style="display:inline; background:yellow">'
                 'Collection Level</a></b>'
                 )
            )
            page = page.replace('%MENUCODE%', read_file('contextMenu.html'))
            page = page.replace('%KYBDCODE%', read_file('keyboard.html'))
            return page
        else:
            return read_file('quotafull.html')

    def _add_revisionDesc(self, rec, fn, local=False):
        tree = rec.get_dom(session)
        filename = fn[fn.rfind('/data/') + 6:]
        if session.user.realName != '':
            userName = session.user.realName
        else:
            userName = session.user.username

        if local:
            textString = ('Uploaded from a local file and edited by {0} '
                          'using the cheshire for archives ead creation and '
                          'editing tool'.format(userName)
                          )
        else:
            textString = ('Loaded from {0} and edited by {1} using the '
                          'cheshire for archives ead creation and editing '
                          'tool' % (filename, userName)
                          )

        if tree.xpath('/ead/eadheader/revisiondesc'):
            if tree.xpath('/ead/eadheader/revisiondesc/change'):
                parent = tree.xpath('/ead/eadheader/revisiondesc')[0]
                new = etree.Element('change')
                date = etree.Element('date')
                date.text = '%s' % datetime.date.today()
                new.append(date)
                item = etree.Element('item')
                item.text = textString
                new.set('audience', 'internal')
                new.append(item)
                parent.append(new)
            elif tree.xpath('/ead/eadheader/revisiondesc/list'):
                parent = tree.xpath('/ead/eadheader/revisiondesc/list')[0]
                item = etree.Element('item')
                item.set('audience', 'internal')
                item.text = '%s on %s' % (textString, datetime.date.today())
                parent.append(item)
        else:
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header,
                                       '/ead/eadheader/revisiondesc/change'
                                       )
            target.set('audience', 'internal')
            target = self._create_path(
                header,
                '/ead/eadheader/revisiondesc/change/date'
            )
            self._add_text(target, '%s' % datetime.date.today())
            target = self._create_path(
                header,
                '/ead/eadheader/revisiondesc/change/item'
            )
            self._add_text(target, textString)
        return LxmlRecord(tree)

    # Loads from editStore

    def load_file(self, form, req):
        recid = form.get('recid', None)
        self.log('LOADING RECORD - %s' % recid)
        found = False
        if not recid:
            return self.show_editMenu()
        try:
            rec = editStore.fetch_record(session, recid)
            found = True
        except:
            try:
                recid = '%s-%s' % (recid, session.user.username)
                rec = editStore.fetch_record(session, recid)
                found = True
            except:
                return self.show_editMenu()
        if found and self._hasPermission(recid):
            li = '<li class="navtab">{0}</li>'.format(keyboard_link)
            self.htmlNav[2] = li
            structure = read_file('ead2002.html')
            htmlform = formTxr.process_record(session, rec).get_raw(session)
            page = structure.replace('%FRM%', htmlform)
            splitId = recid.split('-')
            page = page.replace('%RECID%',
                                ('<input type="hidden" id="recid" value='
                                 '"{0}"/>'.format('-'.join(splitId[:-1]))
                                 )
                                )
            if splitId[-1] == session.user.username:
                page = page.replace(
                    '%PUI%',
                    ('<input type="text" onfocus="setCurrent(this);" '
                     'name="pui" id="pui" size="25" disabled="disabled" '
                     'value="{0}"/>'.format('-'.join(splitId[:-1]))
                     )
                )
            else:
                page = page.replace(
                    '%PUI%',
                    ('<input type="text" onfocus="setCurrent(this);" '
                     'name="pui" id="pui" size="25" disabled="disabled" '
                     'value="{0}"/><input type="hidden" id="owner" '
                     'value="{1}"/>'
                     ''.format('-'.join(splitId[:-1]), splitId[-1])
                     )
                )
            page = page.replace(
                '%TOC%',
                tocTxr.process_record(session, rec).get_raw(session)
            )
            page = page.replace('%MENUCODE%', read_file('contextMenu.html'))
            page = page.replace('%KYBDCODE%', read_file('keyboard.html'))
            return page
        else:
            return ('<p>You do not have permission to perform the action '
                    'requested on the record requested</p>'
                    )

    def _parse_upload(self, data, interface='admin'):
        """."""
        # TODO: figure out why re-encode...!?
        if (type(data) == unicode):
            try:
                data = data.encode('utf-8')
            except:
                try:
                    data = data.encode('utf-16')
                except:
                    # Hope for the best!
                    pass
        doc = StringDocument(data)
        del data
        doc = ppFlow.process(session, doc)
        try:
            rec = xmlp.process_document(session, doc)
        except:
            newlineRe = re.compile('(\s\s+)')
            doc.text = newlineRe.sub('\n\g<1>', doc.get_raw(session))
            # Repeat parse with correct line numbers
            try:
                rec = xmlp.process_document(session, doc)
            except XMLSyntaxError:
                self.htmlTitle.append('Error')
                if interface == 'admin':
                    link = '<a href="files.html">Back to file page</a>'
                else:
                    link = ('<a href="edit.html">Back to edit/create '
                            'menu</a>'
                            )
                exc_type, exc_value, _exc_tb = sys.exc_info()
                self.log('*** %s: %s' % (repr(exc_type), exc_value))
                # Try and highlight error in specified place
                docstr = doc.get_raw(session)
                lines = docstr.split('\n')
                positionRe = re.compile(':(\d+):(\d+):')
                mo = positionRe.search(str(exc_value))
                if mo is None:
                    positionRe = re.compile('line (\d+), column (\d+)')
                    mo = positionRe.search(str(exc_value))
                line, posn = lines[int(mo.group(1)) - 1], int(mo.group(2))

                try:
                    startspace = newlineRe.match(line).group(0)
                except:
                    return ('<div id="single">'
                            '<p class="error">An error occured while '
                            'parsing your file.</p>\n'
                            '<p class="error">{0}</p>'
                            '<p>Please check the file is a '
                            'valid ead file and try again.</p>\n'
                            '<p>{1}</p>\n'
                            '<code>{2}</code>'
                            '</div>'.format(str(exc_value), link, docstr)
                            )
                else:
                    message = ('<div id="single">'
                               '<p class="error">An error occured while '
                               'parsing your file. Please check the file at '
                               'the suggested location and try again.</p>\n'
                               '<code>{0}: {1}</code>'
                               '<pre>'
                               '{2}\n'
                               '<span class="error">{3}{4}</span>'
                               '</pre>'
                               '<p>{5}</p>'
                               '</div>'
                               )
                    pointer = str('-' * (posn - len(startspace))) + '^'
                    return message.format(
                        html_encode(repr(e[0])),
                        e[1],
                        html_encode(line[:posn + 20]) + '...',
                        startspace,
                        pointer,
                        link
                    )
        del doc
        return rec
        # end _parse_upload()

    def upload_local(self, form):
        """Take an uploaded file and put it into the draft file store."""
        f = form.get('filepath', None)
        self.log('LOADING FROM FILE local file store')
        quota = self._get_quota()
        total = self._get_totalDrafts()
        remaining_quota = quota - total
        if remaining_quota < 1:
            return read_file('quotafull.html')
        else:
            if not f or not len(f.value):
                return self.show_editMenu()
            ws = re.compile('[\s]+')
            xml = ws.sub(' ', f.value)
            rec = self._parse_upload(xml, 'edit')
            # TODO: handle file not successfully parsed
            if not isinstance(rec, LxmlRecord):
                return rec
            rec = self._add_componentIds(rec)
            if not rec.process_xpath(session, '/ead/eadheader'):
                return ('<p>Your file is not compatible with the editing '
                        'interface - it requires an eadheader element</p>'
                        )
            else:
                # Add necessary information to record and get id'
                rec = self._add_revisionDesc(rec, '', True)
                rec1 = assignDataIdFlow.process(session, rec)
                recid = rec1.id
                idCheck = self.checkExistingId(recid)
                un = session.user.username
                if idCheck[0] is True:
                    if idCheck[2] is True:
                        return ('<p>You already have this file open for '
                                'editing as {0}.</p>\n'
                                '<p><a href="edit.html?operation=load'
                                '&user=null&recid={0}-{1}">click here</a> '
                                'to continue editing the version of the file '
                                'in the Draft File Store. If you reached '
                                'this page by using the back button from a '
                                'preview of the record then this will take '
                                'you back to the record you were editing.'
                                '<p>\n'
                                '<p>To edit the version from your local file '
                                'store please delete the file currently in '
                                'the Draft File Store before reloading</p>\n'
                                '<p><a href="menu.html">Back to Create/Edit '
                                'Menu</a>'
                                ''.format(recid, un.encode('ascii', 'ignore'))
                                )

                id_ = '{0}-{1}'.format(recid, un.encode('ascii', 'ignore'))
                rec1.id = id_
                # If the file exists in the record store load from there
                # (fixes problems with back button)
                try:
                    rec1 = editStore.fetch_record(session, id_)
                except:
                    # Get the institution of the user performing the operation
                    institutionid = self._get_userInstitutionId(
                        session.user.username
                    )
                    # Otherwise store in editing store and create institution
                    # link
                    editStore.store_record(session, rec1)
                    editStore.link(session,
                                   'linkrecinst',
                                   rec1,
                                   institutionid=institutionid
                                   )

                if not self._hasPermission(rec1.id):
                    return ('<p>You do not have permission to perform the '
                            'action requested on the record requested</p>'
                            )
                else:
                    li = '<li class="navtab">{0}</li>'.format(keyboard_link)
                    self.htmlNav[2] = li
                    structure = read_file('ead2002.html')
                    htmlDoc = formTxr.process_record(session, rec1)
                    htmlform = htmlDoc.get_raw(session)
                    page = structure.replace('%FRM%', htmlform)
                    page = page.replace(
                        '%RECID%',
                        ('<input type="hidden" id="recid" value="{0}"/>'
                         ''.format(recid.encode('ascii'))
                         )
                    )
                    page = page.replace(
                        '%PUI%',
                        ('<input type="text" onfocus="setCurrent(this);" '
                         'name="pui" id="pui" size="25" disabled="true" '
                         'value="{0}"/>'.format(recid.encode('ascii'))
                         )
                    )
                    page = page.replace(
                        '%TOC%',
                        tocTxr.process_record(session, rec1).get_raw(session)
                    )
                    page = page.replace('%MENUCODE%',
                                        read_file('contextMenu.html')
                                        )
                    page = page.replace('%KYBDCODE%',
                                        read_file('keyboard.html')
                                        )
                    return page

    def _hasPermission(self, recid):
        """Confirm/Deny user has permission to edit requested record.

        Return True to confirm or False for whether the current user has
        permission to edit requested record.
        """
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        sqlQ = ("SELECT institutionid "
                "FROM editingstore_linkrecinst "
                "WHERE editingstore=%s LIMIT 1"
                )
        res = editStore._query(sqlQ, (recid,))
        if len(res) == 0:
            return False
        elif len(res) > 1:
            # We have two records with the same id - should never happen
            pass
        else:
            recinst = res[0][0]
        if recinst == authinst:
            return True
        else:
            return False

    def _hasTemplatePermission(self, recid):
        """Confirm/Deny user has permission to edit requested template.

        Return True to confirm or False for whether the current user has
        permission to edit requested template.
        """
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        templateStore = db.get_object(session, 'templateStore')
        sqlQ = ("SELECT institutionid "
                "FROM templatestore_linktempinst "
                "WHERE templatestore='%s'"
                )
        res = templateStore._query(sqlQ, (recid,))
        result = res.dictresult()
        if len(result) == 0:
            return False
        elif len(result) > 1:
            # We have two records with the same is - should never happen
            pass
        else:
            recinst = result[0]['institutionid']
        if recinst == authinst:
            return True
        else:
            return False

    # Validation related functions   ========================================

    def checkExistingId(self, id):
        exists = False
        store = None
        users = []
        overwrite = False
        names = []
        for r in editStore:
            if r.id[:r.id.rfind('-')] == id:
                names.append(r.id[r.id.rfind('-') + 1:])
        if len(names) > 0:
            exists = True
            store = 'editStore'
            for n in names:
                if n == session.user.username:
                    overwrite = True
                else:
                    users.append(n)
        return [exists, store, overwrite, users]

    def getAndCheckId(self, form):
        f = form.get('filepath', None)
        if not f or not len(f.value):
            return '<value>false</value>'
        ws = re.compile('[\s]+')
        try:
            xml = ws.sub(' ', read_file(f))
        except:
            xml = ws.sub(' ', f.value)
        rec = self._parse_upload(xml)
        if not isinstance(rec, LxmlRecord):
            return '<value>false</value>'
        rec = assignDataIdFlow.process(session, rec)
        names = []
        for r in editStore:
            if r.id[:r.id.rfind('-')] == rec.id:
                names.append(r.id[r.id.rfind('-') + 1:])
        if len(names) == 0:
            return '<value>false</value>'
        else:
            ns = []
            for n in names:
                if n != session.user.username:
                    ns.append(n)
            if len(names) == 1 and names[0] == session.user.username:
                return ('<wrap>'
                        '<value>true</value>'
                        '<overwrite>true</overwrite>'
                        '<id>{0}</id>'
                        '</wrap>'.format(rec.id)
                        )
            elif len(names) > 1 and session.user.username in names:
                return ('<wrap>'
                        '<value>true</value>'
                        '<overwrite>true</overwrite>'
                        '<users>{0}</users>'
                        '<id>{1}</id>'
                        '</wrap>'.format(' \n '.join(ns), rec.id)
                        )
            else:
                return ('<wrap>'
                        '<value>true</value>'
                        '<overwrite>false</overwrite>'
                        '<users>{0}</users>'
                        '</wrap>'.format(' \n '.join(ns))
                        )

    def checkId(self, form):
        id = form.get('id', None)
        store = form.get('store', None)
        if store == 'editStore':
            rs = editStore
            id = '%s-%s' % (id, session.user.username)
        if store == 'templateStore':
            rs = db.get_object(session, 'templateStore')
            user = session.user.username
            # Get instId of user
            institutionid = self._get_userInstitutionId(user)
            id = '%s-%s' % (id, institutionid)
        if (id is not None and store is not None):
            exists = 'false'
            for r in rs:
                if r.id == id:
                    exists = 'true'
                    break
            return '<value>%s</value>' % exists

    def checkEditId(self, form):
        id = form.get('id', None)
        rs = editStore
        fullid = '%s-%s' % (id, session.user.username)
        if id is not None:
            exists = 'false'
            for r in rs:
                if r.id == fullid:
                    exists = 'true'
                    break
            if exists == 'false':
                for r in rs:
                    if r.id[:r.id.rfind('-')] == id:
                        exists = 'true'
                        break
                return ('<wrapper>'
                        '<value>{0}</value>'
                        '<owner>other</owner>'
                        '</wrapper>'.format(exists)
                        )
            else:
                return ('<wrapper>'
                        '<value>{0}</value>'
                        '<owner>user</owner>'
                        '</wrapper>'.former(exists)
                        )

    def validate_record(self, xml):
        """Check that xml is well formed and parsable."""
        try:
            etree.fromstring(xml)
        except:
            return False
        else:
            return True

    def validateField(self, form):
        """Check that field is well formed and parsable as XML.

        Called frequently via AJAX to save in the background to alert user
        quickly to any errors, before they navigate away from the offending
        area of the record.
        """
        text = form.get('text', None)
        if '&amp;' in text:
            text = text.replace('&amp;', '&#38;')
        else:
            if '&' in text:
                # Replace lone ampersands
                regex = re.compile('&(?!#[0-9]+;)')
                text = regex.sub('&#38;', text)
        if '<' in text:
            try:
                test = etree.fromstring('<foo>%s</foo>' % text)
            except etree.XMLSyntaxError as e:
                line, col = e.position
                return '''\
<response>
    <valid>false</valid>
    <message>{0}</message>
</response>'''.format(str(e))
        return '<response><valid>true</valid></response>'

    def _get_genericHtml(self, fn):
        global repository_name, repository_link, repository_logo
        html = read_file(fn)
        paramDict = self.globalReplacements
        paramDict.update({'%TITLE%': ' :: '.join(self.htmlTitle),
                          '%NAVBAR%': ' '.join(self.htmlNav)
                          })
        return multiReplace(html, paramDict)

    # Basic User functions - submit preview etc. =============================

    def save_form(self, form):
        """Save the contents of the form to the draft file store.

        Called frequently via AJAX to save in the background before navigating
        between sections, exporting, displaying previews etc.
        """
        loc = form.get('location', None)
        recid = form.get('recid', None)
        parent = form.get('parent', None)
        fileOwner = form.get('owner', session.user.username)
        valid = True
        self.log('Saving Form %s' % recid)
        if (
            loc == 'collectionLevel' and
            (recid is None or recid == 'None')
        ):
            # This is a new collection level file
            # Save the form in any free slot
            (temp, valid) = self.build_ead(form)
            rec = LxmlRecord(temp)
            rec = assignDataIdFlow.process(session, rec)
            recid = rec.id
            rec.id = '%s-%s' % (rec.id, fileOwner)
            # Get the institution of the user performing the operation
            institutionid = self._get_userInstitutionId(session.user.username)
            editStore.store_record(session, rec)
            editStore.link(session,
                           'linkrecinst',
                           rec,
                           institutionid=institutionid
                           )
            # editStore.commit_storing(session)
            return (recid, valid)
        elif (loc == 'collectionLevel'):
            # This is an existing collection level file
            validList = [l for l in self.required_xpaths]
            mylist = form.list
            # Pull existing xml and make into a tree
            retrievedRec = editStore.fetch_record(session,
                                                  '%s-%s' % (recid, fileOwner)
                                                  )
            # Don't simply get_dom in case recordStore does not return
            # LxmlRecords
            # Get the raw XML and parse in lxml.etree instead
            retrievedXml = retrievedRec.get_xml(session)
            tree = etree.fromstring(retrievedXml)
            node = tree.xpath('/ead/archdesc')[0]
            # First delete current accesspoints, languages and digital objects
            self._delete_currentControlaccess(node)
            self._delete_currentLangmaterial(node)
            self._delete_currentDao(node)
            # Change title in header
            header = tree.xpath('/ead/eadheader')[0]
            target = self._create_path(header,
                                       'filedesc/titlestmt/titleproper'
                                       )
            self._add_text(target, form.get('did/unittitle', ''))

            # Add/delete sponsor
            sponsval = form.get('filedesc/titlestmt/sponsor', '').value
            if sponsval.strip() not in ['', ' ']:
                target = self._create_path(header,
                                           'filedesc/titlestmt/sponsor'
                                           )
                self._add_text(target,
                               form.get('filedesc/titlestmt/sponsor', '')
                               )
            else:
                self._delete_path(header, 'filedesc/titlestmt/sponsor')
            valid = self._updateNodeFromFieldList(node, mylist)
            rec = LxmlRecord(tree)
            rec.id = retrievedRec.id
            if self._hasPermission(rec.id):
                editStore.store_record(session, rec)
                return (recid, valid)
            else:
                return ('<p>You do not have permission to perform the '
                        'action requested on the record requested</p>',
                        False
                        )
            # editStore.commit_storing(session)

        # Check if C exists, if not add it, if so replace it
        else:
            # Pull record from store
            retrievedRec = editStore.fetch_record(session,
                                                  '%s-%s' % (recid, fileOwner)
                                                  )
            retrievedXml = retrievedRec.get_xml(session)
            tree = etree.fromstring(retrievedXml)

            # First check there is a dsc element and if not add one (needed
            # for next set of xpath tests)

            if not (tree.xpath('/ead/archdesc/dsc')):
                archdesc = tree.xpath('/ead/archdesc')[0]
                dsc = etree.Element('dsc')
                archdesc.append(dsc)

            if not (tree.xpath('//*[@c3id=\'%s\']' % loc)):
                # Component does not exist; add it
                if parent == 'collectionLevel':
                    parentNode = tree.xpath('/ead/archdesc/dsc')[0]
                else:
                    parentNode = tree.xpath('//*[@c3id=\'%s\']' % parent)[0]
                (rec, valid) = self.build_ead(form)
                parentNode.append(rec)
                rec = LxmlRecord(tree)
                rec.id = retrievedRec.id
                if self._hasPermission(rec.id):
                    editStore.store_record(session, rec)
                    return (recid, valid)
                else:
                    return ('<p>You do not have permission to perform the '
                            'action requested on the record requested</p>',
                            False
                            )
                # editStore.commit_storing(session)
            else:
                # Component does exist; update it
                validList = [l for l in self.required_xpaths_components]
                mylist = form.list
                node = tree.xpath('//*[@c3id=\'%s\']' % loc)[0]
                valid = self._updateNodeFromFieldList(node,
                                                      mylist,
                                                      component=True
                                                      )
                rec = LxmlRecord(tree)
                rec.id = retrievedRec.id
                if self._hasPermission(rec.id):
                    editStore.store_record(session, rec)
                    return (recid, valid)
                else:
                    return ('<p>You do not have permission to perform the '
                            'action requested on the record requested</p>',
                            False
                            )

                # editStore.commit_storing(session)

    def _updateNodeFromFieldList(self, node, fieldlist, component=False):
        # Update the given node in place with values of fields in fieldlist
        # Copy the list of XPaths required for this node
        if component:
            validList = self.required_xpaths_components[:]
        else:
            validList = self.required_xpaths[:]
        # First delete current accesspoints, lang material and dao
        self._delete_currentControlaccess(node)
        self._delete_currentLangmaterial(node)
        self._delete_currentDao(node)
        # Cycle through the form and replace any node that need it
        deleteList = []
        daonames = {}
        self.log(
            ",".join(["{0.name}={0.value}".format(f) for f in fieldlist])
        )
        for field in fieldlist:
            blahlist = ['ctype',
                        'location',
                        'operation',
                        'newForm',
                        'owner',
                        'recid',
                        'parent',
                        'pui',
                        'filedesc/titlestmt/sponsor',
                        'daoselect'
                        ]
            if field.name not in blahlist:
                if field.name.startswith('controlaccess'):
                    # Special handling for complex muli-value controlaccess
                    self._create_controlaccess(node, field.name, field.value)
                    try:
                        validList.remove('controlaccess')
                    except:
                        pass

                elif field.name.startswith('did/langmaterial'):
                    # Special handling for complex muli-value langmaterial
                    if field.name.startswith('did/langmaterial/@'):
                        target = self._create_path(node, field.name)
                        self._add_text(target, field.value)
                    else:
                        did = self._create_path(node, 'did')
                        self._create_langmaterial(did, field.value)
                    try:
                        validList.remove('did/langmaterial/language')
                    except:
                        pass

                elif field.name.startswith('dao'):
                    # Special handling for complex muli-value daos
                    # Just assemble a list now and add them later
                    daoname = field.name.split('|')
                    try:
                        daodict = daonames[daoname[0]]
                    except:
                        daodict = {}
                    fieldval = field.value.strip()
                    if (
                        fieldval not in ['', ' ', '<p></p>'] and
                        re.sub('[\s]+', ' ', fieldval) != '<p> </p>'
                    ):
                        daodict[daoname[1]] = field.value

                    daonames[daoname[0]] = daodict
                else:
                    # Handle remaining fields
                    fieldval = field.value.strip()
                    if (
                        fieldval not in ['', ' ', '<p></p>'] and
                        re.sub('[\s]+', ' ', fieldval) != '<p> </p>'
                    ):
                        target = self._create_path(node, field.name)
                        self._add_text(target, field.value)
                        try:
                            validList.remove(
                                re.sub("\[\d+\]", "", field.name)
                            )
                        except:
                            try:
                                validList.remove(field.name)
                            except:
                                pass
                        # Handle special case of <unitid>
                        # used for persistent identifiers
                        if (
                            field.name.startswith('did/unitid') and
                            field.name.endswith(']')
                        ):
                            # Add @identifier attribute
                            attrPath = field.name + '/@identifier'
                            attr_target = self._create_path(node, attrPath)
                            identVal = field.value
                            # Strip off countrycode
                            try:
                                ccxpath = field.name + '/@countrycode'
                                mycc = node.xpath(ccxpath)[0]
                            except:
                                pass
                            else:
                                if identVal.startswith((mycc,
                                                        mycc.upper(),
                                                        mycc.lower())):
                                    identVal = identVal[len(mycc):]
                                    identVal = identVal.lstrip()
                            # Strip off repositorycode
                            try:
                                rcxpath = field.name + '/@repositorycode'
                                myrc = node.xpath(rcxpath)[0]
                            except:
                                pass
                            else:
                                if identVal.startswith(myrc):
                                    identVal = identVal[len(myrc):]
                                    identVal = identVal.lstrip(' -')
                            self._add_text(attr_target, identVal)
                            # Handle special case of first unitid
                            # (when there isn't already a persistent one)
                            if (
                                field.name == 'did/unitid[1]' and not
                                node.xpath('did/unitid[@type="persistent"]')
                            ):
                                # Add type="persistent"
                                attr_target = self._create_path(target,
                                                                "@type")
                                self._add_text(attr_target, "persistent")

                    else:
                        deleteList.append(field.name)

        if deleteList:
            deleteList.sort(reverse=True)
            for name in deleteList:
                self._delete_path(node, name)
        self._create_dao(daonames, node)
        # Return boolean for whether or not all required XPath were present
        return not bool(validList)

    def delete_record(self, form):
        recid = form.get('recid', None)
        if recid is not None:
            if self._hasPermission(recid):
                editStore.delete_record(session, recid)
                return 'done'
            else:
                return ('<p>You do not have permission to perform the '
                        'action requested on the record requested</p>'
                        )

    def discard_record(self, form):
        recid = form.get('recid', None)
        owner = form.get('owner', session.user.username)
        if recid is not None:
            if self._hasPermission('%s-%s' % (recid, owner)):
                editStore.delete_record(session, '%s-%s' % (recid, owner))
                return 'done'
            else:
                return ('<p>You do not have permission to perform the '
                        'action requested on the record requested</p>'
                        )

    def preview_file(self, form):
        # Adapted from record function in hubSearchHandler
        # (now in hubHandler, JH Oct '11)
        global session, xmlp, repository_name, repository_link
        global repository_logo
        global cache_path, cache_url, toc_cache_path, toc_cache_url
        global toc_scripts, script, fullTxr, fullSplitTxr
        self.htmlTitle.append('Preview File')
        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        if self._hasPermission('%s-%s' % (recid, fileOwner)):
            if recid is not None and recid != 'null':
                rec = editStore.fetch_record(session,
                                             '%s-%s' % (recid, fileOwner)
                                             )
                txr = db.get_object(session, 'orderingTxr')
                doc = txr.process_record(session, rec)
                rec = xmlp.process_document(session, doc)
            else:
                return '<p>No record ID was specified.</p>'
            # ensure restricted access directory exists
            try:
                os.makedirs(os.path.join(cache_path, 'preview'))
                os.makedirs(os.path.join(toc_cache_path, 'preview'))
            except OSError:
                # Already exists
                pass
            pagenum = int(form.getfirst('pagenum', 1))
            self.log('Preview requested')
            # Assign rec.id so that html is stored in a restricted access
            # directory
            recid = rec.id = 'preview/%s' % (session.user.username)
            paramDict = self.globalReplacements
            paramDict.update({'%TITLE%': ' :: '.join(self.htmlTitle),
                              '%NAVBAR%': '',
                             'LINKTOPARENT': '',
                             'TOC_CACHE_URL': toc_cache_url,
                              'RECID': recid,
                              '%TOOLS%': ''
                              })
            try:
                page = self.display_full(rec, paramDict)[pagenum - 1]
            except IndexError:
                return 'No page number %d' % pagenum

            if not (os.path.exists('%s/%s.inc' % (toc_cache_path, recid))):
                page = page.replace(
                    '<!--#include virtual="{0}/{1}.inc"-->'
                    ''.format(toc_cache_url, recid),
                    'There is no Table of Contents for this file.'
                )
            else:
                # Cannot use Server-Side Includes in script generated pages
                # Insert ToC manually
                try:
                    page = page.replace(
                        ('<!--#include virtual="{0}/{1}.inc"-->'
                         ''.format(toc_cache_url, recid)
                         ),
                        read_file('%s/%s.inc' % (toc_cache_path, recid))
                    )
                except:
                    page = page.replace(
                        ('<!--#include virtual="{0}/{1}.inc"-->'
                         ''.format(toc_cache_url, recid)
                         ),
                        ('<span class="error">There was a problem whilst '
                         'generating the Table of Contents</span>'
                         )
                    )
            tmpl = read_file(self.recordTemplatePath)
            tmpl = multiReplace(tmpl, paramDict)
            return tmpl.replace('%CONTENT%', page)
        else:
            return ('<p>You do not have permission to perform the action '
                    'requested on the record requested</p>'
                    )
    #- end preview_file() ---------------------------------------------------

    def display_full(self, rec, paramDict):
        recid = rec.id
        try:
            l = rec.byteCount
        except:
            l = len(rec.get_xml(session))
        if (l < max_page_size_bytes):
            # Nice and short record/component - do it the easy way
            self.log('HTML generated by non-splitting XSLT')
            doc = fullTxr.process_record(session, rec)
        else:
            # Long record - have to do splitting, link resolving etc.
            self.log('HTML generated by splitting XSLT')
            doc = fullSplitTxr.process_record(session, rec)

        # Open, read, and delete tocfile NOW to avoid overwriting screwups
        try:
            tocfile = unicode(
                read_file(os.path.join(toc_cache_path, 'foo.bar')),
                'utf-8'
            )
        except IOError:
            tocfile = None
            try:
                os.remove('%s/%s.inc' % (toc_cache_path, recid))
            except:
                pass
        else:
            os.remove(os.path.join(toc_cache_path, 'foo.bar'))
            tocfile = tocfile.replace('RECID', recid)
        doc = unicode(doc.get_raw(session), 'utf-8')
        del rec

        # before we split need to find all internal anchors
        anchors = anchorRe.findall(doc)
        pseudopages = doc.split('<p style="page-break-before: always"/>')
        if len(pseudopages) == 1:
            pseudopages = doc.split(
                '<p style="page-break-before: always"></p>'
            )

        pages = []
        while pseudopages:
            pagebits = ['<div id="leftcol" class="toc">',
                        ('<!--#config errmsg="[ Table of Contents '
                         'unavailable ]" -->'
                         '<!--#include virtual="/hubedit/tocs/RECID.inc"-->'
                         ),
                        '</div>',
                        '<div id="padder">'
                        '<div id="rightcol" class="ead">'
                        '%PAGENAV%'
                        ]
            while (sum(map(len, pagebits)) < max_page_size_bytes):
                pagebits.append(pseudopages.pop(0))
                if not pseudopages:
                    break

            # Append: pagenav, end rightcol div, padder div, left div
            # (containing toc)
            pagebits.extend(['%PAGENAV%',
                             '<br/>',
                             '</div><!-- end rightcol -->',
                             '</div><!-- end padder -->'
                             ])
            pages.append('\n'.join(pagebits))
        start = 0
        anchorPageHash = {}
        for a in anchors:
            if len(a.strip()) > 0:
                for x in range(start, len(pages), 1):
                    if (pages[x].find('name="%s"' % a) > -1):
                        anchorPageHash[a] = x + 1
                        # Next anchor must be on this page or later
                        start = x
        tmpl = read_file(self.templatePath)
        tmpl = multiReplace(tmpl, paramDict)
        for x, pagex in enumerate(pages):
            # Now we know how many real pages there are,
            # generate some page navigation links
            pagenav = []
            if len(pages) > 1:
                pagenav.extend(['<div class="pagenav">',
                                '<div class="backlinks">'
                                ])
                if (x > 0):
                    pagenav.extend([
                        ('<a href="{0}/{1}-p1.shtml" title="First page"))">'
                         '{2}</a>'.format(cache_url, recid, fback_tag)
                         ),
                        ('<a href="{0}/{1}-p{2}.shtml" title="Previous page">'
                         '{3}</a>'.format(cache_url, recid, x, back_tag)
                         )
                    ])
                pagenav.extend(['</div>', '<div class="forwardlinks">'])
                if (x < len(pages) - 1):
                    pagenav.extend([
                        ('<a href="{0}/{1}-p{2}.shtml" title="Next page">'
                         '{3}</a>'
                         ''.format(cache_url, recid, x + 2, forward_tag)
                         ),
                        ('<a href="{0}/{1}-p{2}.shtml" title="Final page">'
                         '{3}</a>'.format(cache_url,
                                          recid,
                                          len(pages),
                                          fforward_tag
                                          )
                         )
                    ])
                pagenav.extend(['</div>', '<div class="numnav">&#160;'])
                pagenav.extend(['</div> <!--end numnav div -->',
                                '</div> <!-- end pagenav div -->'
                                ])
            else:
                pagename = []
            pagex = pagex.replace('%PAGENAV%', '\n'.join(pagenav))
            # Resolve internal ref links
            for k, v in anchorPageHash.iteritems():
                pagex = pagex.replace('PAGE#%s"' % k,
                                      ('{0}/RECID-p{1}.shtml#{2}"'
                                       ''.format(cache_url, v, k)
                                       )
                                      )

            # Any remaining links were not anchored - encoders fault :(
            # Hope they're on page 1
            pagex = pagex.replace('PAGE#', '%s/RECID-p1.shtml#' % (cache_url))
            pagex = multiReplace(pagex, paramDict)
            pages[x] = pagex
            pagex = pagex.encode('utf-8')
            write_file(
                os.path.join(cache_path, recid + '-p%d.shtml' % (x + 1)),
                tmpl.replace('%CONTENT%', pagex)
            )
        if tocfile:
            try:
                for k, v in anchorPageHash.iteritems():
                    tocfile = tocfile.replace(
                        'PAGE#%s"' % k,
                        '%s/%s-p%d.shtml#%s"' % (cache_url, recid, v, k)
                    )
            except UnboundLocalError:
                pass
            # Any remaining links were not anchored - encoders fault :(
            # Hope they're on page 1
            tocfile = multiReplace(
                tocfile,
                {'SCRIPT': self.script,
                 'PAGE#': '%s/%s-p1.shtml#' % (cache_url, recid)
                 }
            )
            tocfile = '\n'.join([
                '<div id="toc">',
                toc_scripts.replace('%RECID%', recid).replace('RECID', recid),
                tocfile.encode('ascii', 'xmlcharrefreplace'),
                '</div><!-- /toc -->'
            ])
            write_file(os.path.join(toc_cache_path, recid + '.inc'), tocfile)
            os.chmod(os.path.join(toc_cache_path, recid + '.inc'), 0755)
        return pages
        #- end display_full() -----------------------------------------------

    def preview_xml(self, form):
        self.log('XML requested')
        recid = form.get('recid', None)
        markup = form.get('markup', 'hub')
        fileOwner = form.get('owner', session.user.username)
        if self._hasPermission('%s-%s' % (recid, fileOwner)):
            if recid is not None and recid != 'null':
                retrievedRec = editStore.fetch_record(
                    session,
                    '%s-%s' % (recid, fileOwner)
                )
                txr = db.get_object(session, 'orderingTxr')
                outDoc = txr.process_record(session, retrievedRec)
                if markup == 'interop':
                    # Transform to interoperable markup
                    txr = db.get_object(session,
                                        'interoperableEadOutgoingTxr'
                                        )
                    rec = xmlp.process_document(session, outDoc)
                    outDoc = txr.process_record(session, rec)
                    del txr, rec
                return outDoc.get_raw(session)
            else:
                return '<p>Unable to display xml</p>'
        else:
            return ('<p>You do not have permission to perform the action '
                    'requested on the record requested</p>'
                    )

    def savetodisk(self, form, req):
        global session, xmlp, cache_path, cache_url, fullTxr, fullSplitTxr
        try:
            files = glob.glob(
                '%s/files/%s*' % (cache_path, session.user.username)
            )
            for f in files:
                os.remove(f)
        except:
            pass
        self.log('Save to disk requested')
        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        markup = form.get('markup', 'hub')
        if recid is not None and recid != 'null':
            rec = editStore.fetch_record(session,
                                         '%s-%s' % (recid, fileOwner)
                                         )
            txr = db.get_object(session, 'orderingTxr')
            doc = txr.process_record(session, rec)
            rec = xmlp.process_document(session, doc)
            rec.id = '%s-%s' % (recid, fileOwner)
        if not isinstance(rec, LxmlRecord):
            return rec
        # Ensure restricted access directory exists
        try:
            os.makedirs(os.path.join(cache_path, 'files'))
        except OSError:
            # Already exists
            pass
        if self._hasPermission(rec.id):
            if markup == 'interop':
                # Transform to interoperable markup
                txr = db.get_object(session, 'interoperableEadOutgoingTxr')
                interopDoc = txr.process_record(session, rec)
                rec = xmlp.process_document(session, interopDoc)
            f = open(os.path.join(cache_path,
                                  'files',
                                  '%s.xml' % session.user.username
                                  ),
                     'w'
                     )
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            txr = db.get_object(session, 'indentingTxr')
            f.write(txr.process_record(session, rec).get_raw(session))
            f.flush()
            f.close()
            req.headers_out["Content-Disposition"] = ("attachment; "
                                                      "filename={0}.xml"
                                                      "".format(recid)
                                                      )
            req.content_type = "text/plain"
            try:
                req.sendfile(os.path.join(cache_path,
                                          'files',
                                          '%s.xml' % session.user.username)
                             )
            except IOError, e:
                req.content_type = "text/html"
                req.write("Raised exception reads:\n<br>%s" % str(e))
                return apache.OK
            return apache.OK
        else:
            req.write('You do not have permission to perform the action '
                      'requested on the record requested'
                      )
            return apache.OK

    #- end savetodisk() -----------------------------------------------------

    def send_email(self,
                   address=None,
                   recid=None,
                   fileOwner=None,
                   mess=None,
                   markup="hub"
                   ):
        if recid is not None and recid != 'null':
            rec = editStore.fetch_record(session,
                                         '%s-%s' % (recid, fileOwner)
                                         )
            txr = db.get_object(session, 'orderingTxr')
            doc = txr.process_record(session, rec)
            rec = xmlp.process_document(session, doc)
            del txr, doc
            if not isinstance(rec, LxmlRecord):
                return rec
            if markup == 'interop':
                # Transform to interoperable markup
                txr = db.get_object(session, 'interoperableEadOutgoingTxr')
                doc = txr.process_record(session, rec)
                rec = xmlp.process_document(session, doc)
                del txr, doc
        if not isinstance(rec, LxmlRecord):
            return rec
        message = MIMEMultipart()
        sender = '%s@%s' % (outgoing_email_username, outgoing_email_suffix)
        message['From'] = sender
        message['To'] = address
        message['Subject'] = 'EAD record %s' % (recid)
        if mess is None:
            message.attach(
                MIMEText('The EAD record you requested is attached.')
            )
        else:
            message.attach(MIMEText(mess))
        part = MIMEBase('application', "octet-stream")
        txr = db.get_object(session, 'indentingTxr')
        part.set_payload(
            '<?xml version="1.0" encoding="UTF-8"?>\n{0}'
            ''.format(txr.process_record(session, rec).get_raw(session))
        )
        encoders.encode_base64(part)
        part.add_header('Content-Disposition',
                        'attachment; filename="%s.xml"' % recid
                        )
        message.attach(part)
        smtp = smtplib.SMTP()
        smtp.connect(host=outgoing_email_host, port=25)
        smtp.sendmail(sender, address, message.as_string())
        smtp.close()
        return ('''\
        <div id="single">
            <h3 class="bar">File emailed</h3>
            <p>You file has been emailed to the relevant address</p>
            <p><a href="menu.html">Main Menu</a></p>
        </div>''')

    def emailRec(self, form):
        address = form.get('address', None)
        recid = form.get('recid', None)
        owner = form.get('owner', session.user.username)
        markup = form.get('markup', 'hub')
        if self._hasPermission('%s-%s' % (recid, owner)):
            if not address:
                repl = [
                    '<input type="hidden" name="recid" value="%s"/>' % recid,
                    '<input type="hidden" name="owner" value="%s"/>' % owner,
                    '<input type="hidden" name="markup" value="%s"/>' % markup
                ]
                f = read_file('email.html')
                f = f.replace('%Details%', ''.join(repl))
                return (f)
            else:
                return self.send_email(recid=recid,
                                       fileOwner=owner,
                                       address=address,
                                       markup=markup
                                       )
        else:
            return ('<p>You do not have permission to perform the requested '
                    'operation on the requested record</p>'
                    )

    def emailHub(self, form):
        global hubemailaddress
        address = form.get('address', None)
        recid = form.get('recid', None)
        owner = form.get('owner', session.user.username)
        message = form.get('message', '')
        sender = form.get('contact', 'address not supplied')
        message = '%s\n%s' % (sender, message)
        if self._hasPermission('%s-%s' % (recid, owner)):
            if not address:
                repl = [
                    '<input type="hidden" name="recid" value="%s"/>' % recid,
                    '<input type="hidden" name="owner" value="%s"/>' % owner
                ]
                f = read_file('emailhub.html')
                f = f.replace('%Details%', ''.join(repl))
                return (f)
            else:
                return self.send_email(recid=recid,
                                       fileOwner=owner,
                                       address=hubemailaddress,
                                       mess=message
                                       )
        else:
            return ('<p>You do not have permission to perform the requested '
                    'operation on the requested record</p>'
                    )

    def _get_filename(self, rec):
        tree = rec.get_dom(session)
        if tree.xpath('/ead/eadheader/revisiondesc'):
            if tree.xpath('/ead/eadheader/revisiondesc/change'):
                children = tree.xpath(
                    '/ead/eadheader/revisiondesc/change/item'
                )
            elif tree.xpath('/ead/eadheader/revisiondesc/list'):
                children = tree.xpath('/ead/eadheader/revisiondesc/list/item')
            fnre = re.compile('Loaded from ([\S]+) and edited')
            m = re.match(fnre, children[-1].text)
            filename = m.group(1)
            return filename
        else:
            return None

    def add_form(self, form):
        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        if self._hasPermission('%s-%s' % (recid, fileOwner)):
            level = int(form.get('clevel', None))
            stringLevel = '%02d' % (level)
            doc = StringDocument('<c{0}><recid>{1}</recid></c{0}>'
                                 ''.format(stringLevel, recid)
                                 )
            rec = xmlp.process_document(session, doc)
            htmlform = formTxr.process_record(session, rec).get_raw(session)
            htmlform = htmlform.replace(
                '%PUI%',
                ('<input type="text" onfocus="setCurrent(this);" name="pui" '
                 'id="pui" size="25" disabled="true" value="{0}"/>'
                 ''.format(recid)
                 )
            )
            return htmlform
        else:
            return ('<p>You do not have permission to perform the requested '
                    'operation on the requested record</p>'
                    )

    def delete_component(self, form):
        recid = form.get('recid', None)
        fileOwner = form.get('owner', session.user.username)
        if self._hasPermission('%s-%s' % (recid, fileOwner)):
            id_ = form.get('id', None)
            retrievedRec = editStore.fetch_record(
                session,
                '%s-%s' % (recid, fileOwner)
            )
            retrievedXml = retrievedRec.get_xml(session)
            tree = etree.fromstring(retrievedXml)
            comp = tree.xpath('//*[@c3id=\'%s\']' % id_)
            if (len(comp) == 1):
                if (id_.rfind('-') == -1):
                    parent = tree.xpath('//dsc')
                else:
                    parent = tree.xpath(
                        '//*[@c3id=\'%s\']' % id_[:id_.rfind('-')]
                    )
                if len(parent) == 1:
                    parent[0].remove(comp[0])
                    dsc = tree.xpath('//dsc')[0]
                    if len(dsc) == 0:
                        dsc.getparent().remove(dsc)
                    rec = LxmlRecord(tree)
                    rec.id = retrievedRec.id
                    editStore.store_record(session, rec)
                    value = 'true'
                else:
                    value = 'false'

            else:
                value = 'notsaved'
            return '<value>%s</value>' % value
        else:
            return ('<p>You do not have permission to perform the '
                    'requested operation on the requested record</p>'
                    )

    # User edit functions ===================================================

    def show_userMenu(self, values=None, message='', display=None):
        if (
            session.user.has_flag(session,
                                  'info:srw/operation/1/create',
                                  'eadAuthStore'
                                  ) and
            display is None
        ):
            content = self.list_users(values, message)
            return content
        else:
            content = read_file('users.html')
            if values is None:
                values = {'%USERNAME%': session.user.username,
                          '%realName%': '',
                          '%email%': '',
                          '%tel%': ''
                          }
                if session.user.realName:
                    values['%realName%'] = session.user.realName
                if session.user.realName:
                    values['%email%'] = session.user.email
                if session.user.realName:
                    values['%tel%'] = session.user.tel
            values['%message%'] = message
            return multiReplace(content, values)

    def list_users(self, values=None, message=''):
        global authStore
        if values is None:
            values = {'%USERNAME%': '',
                      '%realName%': '',
                      '%email%': '',
                      '%tel%': '',
                      '%message%': ''
                      }
        values['%message%'] = message
        self.htmlTitle.append('User Management')
        lines = ['<div id="single"><h3 class="bar">Current Users </h3>'
                 '<table>',
                 '<tr class="headrow">',
                 '<td>Username</td><td>Real Name</td>',
                 '<td>Email Address</td>',
                 '<td>Telephone</td><td>Operations</td>',
                 '</tr>'
                 ]
        for ctr, uid in enumerate(self._get_usernamesFromMyInst()):
            user = authStore.fetch_object(session, uid)
            if ((ctr + 1) % 2):
                rowclass = 'odd'
            else:
                rowclass = 'even'
            cellstr = ('<td>{0}</td>'
                       '<td>{1.realName</td>'
                       '<td>{1.email}</td>'
                       '<td>{1.tel}</td>'
                       ''.format(uid, user)
                       )
            if (uid == session.user.id):
                cellstr = cellstr + ('<td><a href="users.html?'
                                     'operation=displayedit" '
                                     'class="fileop">EDIT</a></td>'
                                     )
            elif (
                session.user.has_flag(session,
                                      'info:srw/operation/1/delete',
                                      'eadAuthStore'
                                      )
            ):
                cellstr = cellstr + ('<td><a href="users.html?'
                                     'operation=deleteuser&amp;user={0}'
                                     '&confirm=true" class="fileop">'
                                     'DELETE</a></td>'.format(uid)
                                     )
            else:
                cellstr = cellstr + '<td>N/A</td>'
            lines.append('<tr class="%s">%s</tr>' % (rowclass, cellstr))
        lines.append('</table><br/>')
        if (
            session.user.has_flag(session,
                                  'info:srw/operation/1/create',
                                  'eadAuthStore'
                                  )
        ):
            lines.extend(['<h3 class="bar">Add New User</h3>',
                          multiReplace(read_file('adduser.html'), values)
                          ])
        lines.append('</div>')
        return '\n'.join(lines)
        #- end list_users()

    def edit_user(self, form):
        global authStore, rebuild
        values = {'%USERNAME%': form.get('userid', ''),
                  '%realName%': form.get('realName', ''),
                  '%email%': form.get('email', ''),
                  '%tel%': form.get('tel', '')
                  }
        userid = session.user.id
        try:
            user = authStore.fetch_object(session, userid)
        except:
            if (
                session.user.has_flag(session,
                                      'info:srw/operation/1/create',
                                      'eadAuthStore'
                                      )
            ):
                return self.show_userMenu(
                    values,
                    ('<p class="error">User with id "{0}" does not exist!'
                     '</p>'.format(userid)
                     ),
                    'display'
                )
            else:
                return self.show_userMenu(
                    values,
                    ('<p class="error">User with id "{0}" does not exist!'
                     '</p>'.format(userid)
                     )
                )

        if (form.get('submit', None)):
            userRec = authStore.fetch_record(session, userid)
            userNode = userRec.get_dom(session)
            passwd = form.get('passwd', None)
            # Check password
            if (passwd and user.check_password(session, passwd)):
                newHash = {}
                for f in user.simpleNodes:
                    if form.has_key(f):
                        newHash[f] = form.getfirst(f)
                passwd1 = form.get('passwd1', None)
                if (passwd1 and passwd1 != ''):
                    passwd2 = form.get('passwd2', None)
                    if (passwd1 == passwd2):
                        newHash['password'] = crypt(passwd1, passwd1[:2])
                    else:
                        if (
                            session.user.has_flag(
                                session,
                                'info:srw/operation/1/create',
                                'eadAuthStore'
                            )
                        ):
                            return self.show_userMenu(
                                values,
                                ('<p class="error">Unable to update details'
                                 ' - new passwords did not match.</p>'
                                 ),
                                'display'
                            )
                        else:
                            return self.show_userMenu(
                                values,
                                ('<p class="error">Unable to update details '
                                 '- new passwords did not match.</p>'
                                 )
                            )
                # Update DOM
                userNode = self._modify_userLxml(userNode, newHash)
                self._submit_userLxml(userid, userNode)
                user = authStore.fetch_object(session, userid)
                rebuild = True
                if (
                    session.user.has_flag(session,
                                          'info:srw/operation/1/create',
                                          'eadAuthStore'
                                          )
                ):
                    values = {'%USERNAME%': '',
                              '%realName%': '',
                              '%email%': '',
                              '%tel%': '',
                              '%message%': ''
                              }
                    return self.show_userMenu(values, '')
                else:
                    return self.show_userMenu(
                        values,
                        '<p class="ok">Details successfully updated.</p>'
                    )
            else:
                if (
                    session.user.has_flag(session,
                                          'info:srw/operation/1/create',
                                          'eadAuthStore'
                                          )
                ):
                    return self.show_userMenu(
                        values,
                        ('<p class="error">Unable to update details - '
                         'current password missing or incorrect.</p>'
                         ),
                        'display'
                    )
                else:
                    return self.show_userMenu(
                        values,
                        ('<p class="error">Unable to update details - '
                         'current password missing or incorrect.</p>'
                         )
                    )
        else:
            return self.show_userMenu()
    #- end edit_user()

    def delete_user(self, form):
        global authStore, rebuild
        userid = form.get('user', None)
        cancel = form.get('cancel', None)
        confirm = form.get('confirm', None)
        passwd = form.get('passwd', None)
        if confirm == 'true':
            output = [
                '<div id="maincontent">',
                '<h3 class="bar">Delete User Confirmation.</h3>',
                read_file('deleteuser.html').replace('%USERID%', userid),
                '</div>'
            ]
            return ''.join(output)
        elif cancel == 'Cancel':
            return self.show_userMenu()
        else:
            if (
                passwd and
                session.user.check_password(session, passwd)
            ):
                if (
                    self._canDelete(userid) and
                    session.user.has_flag(session,
                                          'info:srw/operation/1/delete',
                                          'eadAuthStore'
                                          )
                ):
                    try:
                        authStore.delete_record(session, userid)
                    except:
                        return self.show_userMenu(
                            None,
                            ('<p class="error">Unable to delete user {0} - '
                             'user does not exist.</p>'.format(userid)
                             )
                        )
                    else:
                        rebuild = True
                        return self.show_userMenu()
                else:
                    return self.show_userMenu(
                        None,
                        ('<p class="error">Unable to delete user {0} - '
                         'you do not have permission to perform this '
                         'operation.</p>'.format(userid)
                         )
                    )
            else:
                return self.show_userMenu(
                    None,
                    ('<p class="error">Unable to delete user {0} - '
                     'incorrect password.</p>'.format(userid)
                     )
                )

    def _canDelete(self, userid):
        global session
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        userinst = self._get_userInstitutionId(userid)
        if userinst == authinst:
            return True
        else:
            return False

    def add_user(self, form):
        values = {'%USERNAME%': form.get('userid', ''),
                  '%realName%': form.get('realName', ''),
                  '%email%': form.get('email', ''),
                  '%tel%': form.get('tel', '')
                  }
        if (form.get('submit', None)):
            userid = form.get('userid', None)
            if userid:
                userid = userid.value
            if not (userid and userid.isalnum()):
                if not userid:
                    message = ('Unable to add user - '
                               'you MUST supply a username'
                               )
                else:
                    message = ('Unable to add user - username may only '
                               'comprise alphanumeric characters.'
                               )
                values['%USERNAME%'] = ''
                return self.show_userMenu(values,
                                          '<p class="error">%s</p>' % message
                                          )
            try:
                user = authStore.fetch_object(session, userid)
            except ObjectDoesNotExistException:
                user = None
            if user is not None:
                values['%USERNAME%'] = ''
                msg = '''
                <p class="error">
                User with username/id "{0}" already exists!
                Please try again with a different username.
                </p>
                '''.format(userid)
                return self.show_userMenu(values, msg)
            else:
                # we do want to add this user
                userXML = new_user_template.replace('%USERNAME%', userid)
                userRec = xmlp.process_document(session,
                                                StringDocument(userXML)
                                                )
                userNode = userRec.get_dom(session)
                passwd = form.get('passwd', None)
                # check password
                newHash = {}
                for f in session.user.simpleNodes:
                    if form.has_key(f):
                        newHash[f] = form.getfirst(f)
                passwd1 = form.get('passwd1', None)
                if (passwd1 and passwd1 != ''):
                    passwd2 = form.get('passwd2', None)
                    if (passwd1 == passwd2):
                        newHash['password'] = crypt(passwd1, passwd1[:2])
                    else:
                        return self.show_userMenu(
                            values,
                            ('<p class="error">Unable to add user - '
                             'passwords did not match.</p>')
                        )
                else:
                    return self.show_userMenu(
                        values,
                        ('<p class="error">Unable to add user - '
                         'password not supplied.</p>')
                    )
                inst = self._get_userInstitutionId(session.user.id)
                # Update DOM
                userNode = self._modify_userLxml(userNode, newHash)
                self._submit_userLxml(userid, userNode)
                # Need to fetch user as record in order for link function to
                # work
                user = authStore.fetch_record(session, userid)
                authStore.link(session,
                               'linkAuthInst',
                               user,
                               institutionId=inst
                               )
                rebuild = True
                values['%USERNAME%'] = ''
                values['%realName%'] = ''
                values['%email%'] = ''
                values['%tel%'] = ''
                return self.show_userMenu(values)
        return self.show_userMenu(values)
        #- end add_user()

    def _modify_userLxml(self, userNode, updateHash):
        for c in userNode.iterchildren(tag=etree.Element):
            if c.tag in updateHash:
                c.text = updateHash[c.tag]
                del updateHash[c.tag]
        for k, v in updateHash.iteritems():
            el = etree.SubElement(userNode, k)
            el.text = v
        return userNode
        #- end _modify_userLxml()

    def _submit_userLxml(self, id, userNode):
        rec = LxmlRecord(userNode)
        rec.id = id
        authStore.store_record(session, rec)
        authStore.commit_storing(session)
        #- end _submit_userLxml()

    # Menu page functions ===================================================

    def reassign_record(self, form):
        newUser = form.get('user', None).value
        recid = form.get('recid', None).value
        rec = editStore.fetch_record(session, recid)
        if (
            self._hasPermission(recid) and
            session.user.has_flag(session,
                                  'info:srw/operation/1/create',
                                  'eadAuthStore'
                                  )
        ):
            if rec.id[rec.id.rfind('-') + 1:] == newUser:
                return recid
            else:
                institutionid = self._get_userInstitutionId(newUser)
                rec.id = ('%s-%s') % (rec.id[:rec.id.rfind('-')], newUser)
                editStore.delete_record(session, recid)
                editStore.store_record(session, rec)
                editStore.link(session,
                               'linkrecinst',
                               rec,
                               institutionid=institutionid
                               )
                #editStore.commit_storing(session)
                return rec.id
        else:
            return ('<p>You do not have permission to perform the requested '
                    'operation on the requested record</p>'
                    )

    def _get_usernamesByInst(self, institutionid):
        """Return usernames from institution in alphabetical order."""
        sqlQ = ("SELECT eadAuthStore "
                "FROM eadAuthStore_linkauthinst "
                "WHERE institutionid=%s "
                "ORDER BY eadAuthStore ASC"
                )
        res = authStore._query(sqlQ, (institutionid,))
        return sorted([r[0] for r in res], key=str.lower)

    def _get_usernamesFromMyInst(self):
        """Get and return usernames from same institution.

        Return usernames from same institution as user in alphabetical order.
        """
        institutionid = self._get_userInstitutionId(session.user.username)
        return self._get_usernamesByInst(institutionid)

    def _get_templatesByInst(self):
        result = []
        institutionid = self._get_userInstitutionId(session.user.username)
        sqlQ = ("SELECT templatestore "
                "FROM templatestore_linktempinst "
                "WHERE institutionid=%s"
                )
        res = authStore._query(sqlQ, (institutionid,))
        return res

    def show_editMenu(self):
        page = read_file('editmenu.html')
        # Get template info
        templateStore = db.get_object(session, 'templateStore')
        options = []
        for ctr, r in enumerate(self._get_templatesByInst()):
            id = r[0]
            options.append('<option value="{0}">{1}</option>'
                           ''.format(id, id[:id.rfind('-')])
                           )
        if len(options) == 0:
            templateSel = ''
            templateMod = ''
        else:
            templateSel = ('<select name="templatesel1">'
                           '<option value="blank">No Template</option>'
                           '{0}</select><br/><br/>'.format(''.join(options))
                           )
            templateMod = [
                '<p>Modify an existing template</p>',
                '<form name="templateform" action="edit.html" method="get">',
                ('<input type="hidden" name="operation" '
                 'value="modifytemplate"/>'),
                ('<select name="templatesel2">{0}</select><br/><br/>'
                 '<input type="submit" value=" Modify Template " '
                 'disabled="true"/>'.format(''.join(options))
                 ),
                '</form>'
            ]

        # Get user/Insititution info
        recids = self._walk_store(editStore, 'radio')
        if (
            session.user.has_flag(session,
                                  'info:srw/operation/1/create',
                                  'eadAuthStore')
        ):
            self.htmlNav[2] = '''\
            <li class="navtab">
                <a href="users.html" title="Manage User Accounts">
                    <img src="/images/editor/icon-user.png" alt=""/>
                    Manage Users
                </a>
            </li>'''
            userStore = db.get_object(session, 'eadAuthStore')
            users = []
            for ctr, uid in enumerate(self._get_usernamesFromMyInst()):
                user = userStore.fetch_object(session, uid)
                users.append('<option value="{0.username}">{0.username}'
                             '</option>'.format(user)
                             )
            assignmentOptn = '''\
            <select id="userSelect" name="user" disabled="true">
                <option value="null">Reassign to...</option>
                {0}
            </select>
            <input type="button" onclick="reassignToUser()"
                value=" Confirm Reassignment " disabled="true"/>
            '''.format(''.join(users))
        else:
            assignmentOptn = ''
            self.htmlNav[2] = '''\
            <li class="navtab">
                <a href="users.html" title="Edit Account Details">
                    <img src="/images/editor/icon-user.png" alt=""/>
                    Edit Account Details
                </a>
            </li>'''

        # Check quotas
        quota = self._get_quota()
        total = self._get_totalDrafts()
        # If less than 10 of quota remain
#        if quota - total <= 10:
        # If less than 20% of quota remain
        if float(total) / quota >= 0.8:
            classtype = 'error'
        else:
            classtype = 'ok'
        return multiReplace(page, {'%%%RECORDS%%%': ''.join(recids),
                                   '%%%USROPTNS%%%': assignmentOptn,
                                   '%%%TOTAL%%%': total,
                                   '%%%QUOTA%%%': quota,
                                   '%%%CLASS%%%': classtype,
                                   '%%%TMPLTSEL%%%': templateSel,
                                   '%%%TMPLTMOD%%%': ''.join(templateMod)
                                   }
                            )

    def _get_totalDrafts(self):
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        countsql = ("SELECT COUNT(editingstore) as total "
                    "FROM editingstore_linkrecinst "
                    "WHERE institutionid = %s"
                    )
        res2 = editStore._query(countsql, (authinst,))
        total = res2[0][0]
        return total

    def _get_quota(self):
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        instStore = db.get_object(session, 'institutionStore')
        inst = instStore.fetch_record(session, authinst)
        quota = inst.process_xpath(session, '//quota/text()')[0]
        return int(quota)

    def _walk_store(self, store, type='checkbox'):
        institutionid = self._get_userInstitutionId(session.user.username)
        sqlQ = ("SELECT DISTINCT editingstore "
                "FROM editingstore_linkrecinst "
                "WHERE institutionid=%s "
                "ORDER BY editingstore"
                )
        records = authStore._query(sqlQ, (institutionid,))
        out = []
        names = []
        total = 0
        for name in self._get_usernamesByInst(institutionid):
            names.append(name)
            if (
                name == session.user.username or
                session.user.has_flag(session,
                                      'info:srw/operation/1/create',
                                      'eadAuthStore'
                                      )
            ):
                disabled = ''
            else:
                disabled = 'disabled="disabled"'
            userFiles = [('<li title="{0}" id="{0}"><span>{0}</span>'
                          ''.format(name)
                          ),
                         '<ul class="hierarchy">'
                         ]
            for s in records:
                recid = s[0]
                if recid[recid.rfind('-') + 1:] == name:
                    try:
                        displayId = recid[:recid.rindex('-')]
                    except:
                        displayId = recid
                    userFiles.extend([
                        '<li>',
                        '<span class="fileops">',
                        ('<input type="{0}" name="recid" value="{1}" {2}/>'
                         '</span>'.format(type, recid, disabled)
                         ),
                        '<span class="filename">%s</span>' % displayId,
                        '</li>'
                    ])
                    total += 1
            userFiles.append('</ul></li>')
            out.append(''.join(userFiles))
        sqlQ = ("SELECT DISTINCT editingstore "
                "FROM editingstore_linkrecinst "
                "WHERE institutionid=%s"
                )
        res = authStore._query(sqlQ, (institutionid,))
        if total < len(res):
            out.extend(['<li title=deletedUsers><span>Deleted Users</span>',
                        '<ul class="hierarchy">'
                        ])
            if (
                session.user.has_flag(session,
                                      'info:srw/operation/1/create',
                                      'eadAuthStore')
            ):
                disabled = ''
            else:
                disabled = 'disabled="disabled"'
            for r in res:
                recid = r[0]
                if recid[recid.rfind('-') + 1:] not in names:
                    try:
                        displayId = recid[:recid.rindex('-')]
                    except:
                        displayId = recid
                    out.extend([
                        '<li>',
                        '<span class="fileops">',
                        ('<input type="{0}" name="recid" value="{1}" {2}/>'
                         '</span>'.format(type, recid, disabled)),
                        '<span class="filename">{0}</span>'.format(displayId),
                        '</li>'
                    ])
            out.append('</ul>')
        return out

    #========================================================================

    def log(self, txt):
        try:
            self.logger.log(txt)
        except AttributeError:
            pass

    def handle(self, req):
        global script, editStore
        self.htmlTitle = ['Data Creation and Editing']
        self.htmlNav = [
            '''<li class="navtab">
                <a href="menu.html" target="_top" title="Edit/Create Menu">
                    <img src="/images/editor/icon-list.png" alt=""/>
                    Edit/Create Menu
                </a>
            </li>
            ''',
            '''<li class="navtab">
                <a href="http://www.archiveshub.ac.uk/arch/eadeditorhelp.shtml"
                   target="_new" title="Edit/Create Help">
                    <img src="/images/editor/icon-help.png" alt=""/>
                    Edit/Create Help
                </a>
            </li>
            ''',
            ''
        ]
        form = FieldStorage(req, True)
        content = None
        operation = form.get('operation', None)
        path = req.uri[1:]
        path = path[path.rfind('/') + 1:]
        if path == 'users.html':
            if (operation):
                if (operation == 'edituser'):
                    content = self.edit_user(form)
                elif (operation == 'adduser'):
                    content = self.add_user(form)
                elif (operation == 'deleteuser'):
                    content = self.delete_user(form)
                elif (operation == 'displayedit'):
                    content = self.show_userMenu(None, '', 'display')
                else:
                    content = self.show_userMenu()
            else:
                content = self.show_userMenu()
            page = multiReplace(read_file(templatePath),
                                self.globalReplacements
                                )
            page = multiReplace(page,
                                {'%TITLE%': ' :: '.join(self.htmlTitle),
                                 '%NAVBAR%': ' '.join(self.htmlNav),
                                 '%CONTENT%': content
                                 }
                                )
            # send the display
            self.send_html(page, req)
        elif (operation):
            editStore.begin_storing(session)
            if (operation == 'add'):
                content = self.add_form(form)
                self.send_html(content, req)
            elif (operation == 'delete'):
                content = self.delete_component(form)
                self.send_xml(content, req)
            elif (operation == 'save'):
                (content, valid) = self.save_form(form)
                self.send_xml('<wrap>'
                              '<recid>{0}</recid>'
                              '<valid>{1}</valid>'
                              '<username>{2}</username>'
                              '</wrap>'.format(content,
                                               valid,
                                               session.user.username
                                               ),
                              req
                              )
            elif (operation == 'deleteRec'):
                content = self.delete_record(form)
                self.send_xml(content, req)
            elif (operation == 'disk'):
                self.savetodisk(form, req)
            elif (operation == 'email'):
                content = self.emailRec(form)
                self.send_fullHtml(content, req)
            elif (operation == 'emailhub'):
                content = self.emailHub(form)
                self.send_fullHtml(content, req)
            elif (operation == 'discard'):
                content = self.discard_record(form)
                self.send_xml('<recid>%s</recid>' % content, req)
            elif (operation == 'reassign'):
                content = self.reassign_record(form)
                self.send_xml('<recid>%s</recid>' % content, req)
            elif (operation == 'navigate'):
                content = self.navigate(form)
                self.send_html(content, req)
            elif (operation == 'xml'):
                content = self.preview_xml(form)
                self.send_xml(content, req)
            elif (operation == 'preview'):
                content = self.preview_file(form)
                self.send_html(content, req)
            elif (operation == 'checkId'):
                content = self.checkId(form)
                self.send_xml(content, req)
            elif (operation == 'checkEditId'):
                content = self.checkEditId(form)
                self.send_xml(content, req)
            elif (operation == 'getCheckRecStoreId'):
                content = self.getAndCheckRecStoreId(form)
                self.send_xml(content, req)
            elif (operation == 'getCheckId'):
                content = self.getAndCheckId(form)
                self.send_xml(content, req)
            elif (operation == 'validate'):
                content = self.validateField(form)
                self.send_xml(content, req)
            elif (operation == 'load'):
                content = self.load_file(form, req)
                self.send_fullHtml(content, req)
            elif (operation == 'create'):
                content = self.generate_file(form)
                self.send_fullHtml(content, req)
            elif (operation == 'local'):
                content = self.upload_local(form)
                self.send_fullHtml(content, req)
            elif (operation == 'createtemplate'):
                content = self.create_template(form)
                self.send_fullHtml(content, req)
            elif (operation == 'savetemplate'):
                content = self.save_template(form)
                self.send_xml(content, req)
            elif (operation == 'modifytemplate'):
                content = self.modify_template(form)
                self.send_fullHtml(content, req)
            elif (operation == 'discardtemplate'):
                content = self.discard_template(form)
            editStore.commit_storing(session)
        else:
            path = req.uri
            location = path[path.rfind('/'):]
            if location == '/nojavascript.html':
                content = read_file('nojavascript.html')
            elif location == '/help.html':
                content = read_file('edithelp.html')
            else:
                content = self.show_editMenu()
            page = multiReplace(read_file(templatePath),
                                self.globalReplacements
                                )
            page = multiReplace(page,
                                {'%TITLE%': ' -- '.join(self.htmlTitle),
                                 '%NAVBAR%': ' '.join(self.htmlNav),
                                 '%CONTENT%': content
                                 }
                                )
            # send the display
            self.send_html(page, req)

        # end handle() ------------------------------------------------------
    # end class EadEditingHandler -------------------------------------------

# Some stuff to do on initialisation


rebuild = True
serv = None
session = None
db = None
editStore = None
authStore = None
assignDataIdFlow = None
xmlp = None
formTxr = None
tocTxr = None
logfilepath = editinglogfilepath


def build_architecture(data=None):
    global session, serv, db, editStore, authStore, formTxr, tocTxr, xmlp
    global assignDataIdFlow, ppFlow, fullTxr, fullSplitTxr
    global rebuild
    # Discover objects
    session = Session()
    session.database = 'db_hubedit'
    session.environment = 'apache'
    session.user = None
    serv = SimpleServer(session,
                        os.path.join(cheshire3Root,
                                     'configs',
                                     'serverConfig.xml'
                                     )
                        )
    db = serv.get_object(session, 'db_hubedit')
    editStore = db.get_object(session, 'editingStore')
    authStore = db.get_object(session, 'eadAuthStore')
    assignDataIdFlow = db.get_object(session, 'assignDataIdentifierWorkflow')

    # transformers
    xmlp = db.get_object(session, 'LxmlParser')
    formTxr = db.get_object(session, 'formCreationTxr')
    tocTxr = db.get_object(session, 'editingTocTxr')
    ppFlow = db.get_object(session, 'preParserWorkflow')
    ppFlow.load_cache(session, db)
    fullTxr = db.get_object(session, 'htmlFullTxr')
    fullSplitTxr = db.get_object(session, 'htmlFullSplitTxr')
    rebuild = False


def handler(req):
    global rebuild, logfilepath, cheshirePath, hubEditingHandler
    script = req.subprocess_env['SCRIPT_NAME']
    try:
        remote_host = req.get_remote_host(apache.REMOTE_NOLOOKUP)
        # cd to where html fragments are
        os.chdir(htmlPath)
        # Initialise logger object
        lgr = FileLogger(logfilepath, remote_host)
        hubEditingHandler.logger = lgr
        # handle request
        try:
            #cProfile.runctx('hubEditingHandler.handle(req)',
            #                globals=globals(),
            #                locals=locals(),
            #                filename='../logs/menuloadstat'
            #                )
            hubEditingHandler.handle(req)
        finally:
            try:
                hubEditingHandler.logger.flush()
            except:
                pass

            hubEditingHandler.logger = None
            del lgr
    except:
        # send error to log file
        # don't send CGI friendly error, it hides errors from AJAX
        cla, exc, trbk = sys.exc_info()
        excName = cla.__name__
        try:
            excArgs = exc.__dict__["args"]
        except KeyError:
            excArgs = str(exc)
        excTb = traceback.format_tb(trbk, 100)
        req.log_error('*** {0}: {1} ; {2}'.format(excName,
                                                  excArgs,
                                                  '; '.join(excTb)
                                                  )
                      )
        return apache.HTTP_INTERNAL_SERVER_ERROR
    else:
        return apache.OK
    #- end handler()


def authenhandler(req):
    global session, authStore, rebuild
    if (rebuild):
        # Build the architecture
        build_architecture()
    pw = req.get_basic_auth_pw()
    un = req.user
    try:
        u = session.user = authStore.fetch_object(session, un)
    except ObjectDoesNotExistException:
        return apache.HTTP_UNAUTHORIZED
    if u.check_password(session, pw):
        return apache.OK
    else:
        return apache.HTTP_UNAUTHORIZED
    #- end authenhandler()


def asciiFriendly(mo):
    return "&#%s;" % ord(mo.group(1))


nonAsciiRe = re.compile('([\x7b-\xff])')
anchorRe = re.compile('<a .*?name="(.*?)".*?>')

# Initialise handler
hubEditingHandler = HubEditingHandler()
