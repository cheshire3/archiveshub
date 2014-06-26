#
# Script:    eadEditingHandler.py
# Version:   0.02
# Date:      21/10/2010
# Copyright: &copy; University of Liverpool 2010
# Description:
#            Data creation and editing interface for EAD finding aids
#            - part of Cheshire for Archives v3
#
# Author(s): CS - Catherine Smith <catherine.smith@liv.ac.uk>
#            JH - John Harrison <john.harrison@liv.ac.uk>
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
# 0.01 - 06/12/2008 - JH - Basic administration navigations and menus
# 0.02 - 21/10/2010 - JH - New branding applied
# 0.03 - xx/06/2011 - JH - Institutions and their users listed in alphabetical
#                          order
#                        - Bug fix enabling deletion of Institutional
#                          administative users
#                        - Redirect to admin/ to prevent URL collisions from
#                          relative links
#                        - New feature enables editing (including resetting
#                          password) of any EAD Editor user
#

import sys
import os
import cgitb
import time
import re
import smtplib
import datetime

from lxml import etree
from crypt import crypt
from os.path import abspath

from mod_python import apache, Cookie
from mod_python.util import FieldStorage, redirect

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer
from cheshire3.baseObjects import Session
from cheshire3.utils import flattenTexts
from cheshire3.document import StringDocument
from cheshire3.record import LxmlRecord
from cheshire3.web import www_utils

from cheshire3 import exceptions as c3errors
from cheshire3.internal import cheshire3Root

from cheshire3.web.www_utils import FileLogger, read_file, multiReplace

from .hubeditLocalConfig import *


class HubeditAdminHandler:

    templatePath = os.path.join(cheshirePath,
                                'www',
                                'hubedit',
                                'html',
                                )
    baseTemplatePath = os.path.join(templatePath,
                                    'template.html'
                                    )

    def __init__(self, lgr):
        self.htmlTitle = ['Administration']
        self.htmlNav = [
            '<li class="navtab">'
            '<a href="/edit/menu.html" title="Edit/Create Menu">'
            '<img src="/images/editor/icon-list.png" alt=""/>'
            'Edit/Create Menu'
            '</a>'
            '</li>'
        ]
        self.logger = lgr

    def send_response(self, data, req, content_type=None, code=200):
        if content_type is not None:
            req.content_type = content_type
        req.headers_out['Cache-Control'] = "no-cache, no-store"
        req.send_http_header()
        if (type(data) == unicode):
            data = data.encode('utf-8')
        req.write(data)
        req.flush()
        #- send_response() ---------------------------------------------------

    def send_html(self, data, req, code=200):
        self.send_response(data, req, 'text/html; charset=utf-8', code)
        #- send_html() -------------------------------------------------------

    def send_xml(self, data, req, code=200):
        self.send_response(data, req, 'application/xml', code)
        #- end send_xml() ----------------------------------------------------

    def show_adminMenu(self, values=None, message=''):
        page = read_file('adminmenu.html')
        if values is None:
            values = {'%USERNAME%' :  '',
                      '%FULLNAME%' : '',
                      '%EMAIL%' : '',
                      '%TELEPHONE%' : '',
                      '%USER%' :'',
                      '%SUPERUSER%' : 'checked="checked"'
                      }
        page = page.replace('%MESSAGE%', message)
        page = page.replace('%INSTSELECT%', self.create_select())
        page = page.replace('%INSTUSERLIST%', self.list_usersByInst())
        page = page.replace('%INSTSELECTOPTIONS%', self.get_institutions())
        page = multiReplace(page, values)
        return page

    def show_userEdit(self, values, message=''):
        page = read_file('users.html')
        values['%message%'] = message
        return multiReplace(page, values)

    def edit_user(self, form):
        global userStore
        userid = form.get('userid', None)
        try:
            user = userStore.fetch_object(session, userid)
        except c3errors.ObjectDoesNotExistException:
            return self.show_adminMenu(
                None,
                '<p class="error">Unable to edit user - '
                'user does not exist.</p>'
            )
        values = {'%USERNAME%': userid,
                  '%realName%': user.realName,
                  '%email%': user.email,
                  '%tel%': user.tel
                  }
        if (form.get('submit', None) is None):
            # request for editing form
            return self.show_userEdit(values)
        else:
            newHash = {}
            for f in user.simpleNodes:
                val = form.getfirst(f, None)
                if val is not None:
                    newHash[f] = val
                    values["%{0}%".format(f)] = val
            passwd = form.get('passwd', None)
            # check hubedit admin user password confirmation
            if (passwd and not session.user.check_password(session, passwd)):
                return self.show_userEdit(
                    values,
                    '<p class="error">Unable to edit user - '
                    'incorrect password confirmation.</p>'
                )
            elif not passwd:
                return self.show_userEdit(
                    values,
                    '<p class="error">Unable to edit user - '
                    'missing password confirmation.</p>'
                )
            # check for new passwords
            passwd1 = form.get('passwd1', None)
            if passwd1:
                passwd2 = form.get('passwd2', None)
                if (passwd1 != passwd2):
                    return self.show_userEdit(
                        values,
                        '<p class="error">Unable to update details - '
                        'new passwords did not match.</p>'
                    )
                else:
                    # continue with editing
                    newHash['password'] = crypt(passwd1, userid)
            userRec = userStore.fetch_record(session, userid)
            userNode = userRec.get_dom(session)
            # update DOM
            userNode = self._modify_userLxml(userNode, newHash)
            self._submit_userLxml(userid, userNode)
            return self.show_adminMenu(
                None,
                '<p class="ok">User details successfully updated.</p>'
            )
        #- end edit_user()

    def list_usersByInst(self):
        global userStore
        out = []
        # Get list of institutions for sorting
        institutions = []
        for instRec in instStore:
            instName = instRec.process_xpath(session, '//name/text()')[0]
            institutions.append((instName, instRec))
        for instName, instRec in sorted(institutions):
            sqlQ = ("SELECT hubAuthStore FROM hubAuthStore_linkauthinst "
                    "WHERE institutionid=%s ORDER BY hubAuthStore"
                    )
            result = userStore._query(sqlQ, (instRec.id,))
            quota = instRec.process_xpath(session, '//quota/text()')[0]
            instUsers = [u'<li title="{0}">'.format(instName),
                         u'<span>{0} [{1}]</span>'.format(instName, quota)
                         ]
            if len(result):
                instUsers.append(u'<ul class="hierarchy">')
                for r in result:
                    username = r[0]
                    user = userStore.fetch_object(session, username)
                    if user.has_flag(
                        session,
                        'info:srw/operation/1/create',
                        'hubAuthStore'
                    ):
                        userText = '{0} (Administrator)'.format(username)
                    else:
                        userText = username
                    instUsers.append(u'''\
                    <li>
                      <a href="users.html?operation=edit&amp;userid={0}">
                      {1}
                      </a>
                      <a onclick="deleteUser(\'{0}\')"
                          class="delete-sprite">
                          [&times;]
                      </a>
                    </li>'''.format(username, userText)
                    )
                instUsers.append(u'</ul>')
            else:
                instUsers.extend([
                    u'''<a onclick="deleteInst(\'{0}\')"
                        class="delete-sprite"
                        title="Delete institution '{1}'">
                        [&times;]
                    </a>'''.format(instRec.id, instName),
                    u'<ul class="hierarchy"></ul>'
                ])
            instUsers.append(u'</li>')
            out.extend(instUsers)
        return u''.join(out)

    def get_institutions(self):
        optionList = []
        for rec in instStore:
            option = ('<option value="{0}|{1}|{2}">{3}</option>'
                      ''.format(
                          rec.id,
                          rec.process_xpath(session, '//name/text()')[0],
                          rec.process_xpath(session, '//quota/text()')[0],
                          rec.process_xpath(session, '//name/text()')[0]
                          )
                      )
            optionList.append(option)
        return ''.join(optionList)

    def create_select(self):
        optionList = []
        optionList.append('<option value="null">Select</option>')
        for i in instStore:
            optionList.append(
                '<option value="{0}">{1}</option>'
                ''.format(i.id, i.process_xpath(session, '//name/text()')[0])
            )
        return ''.join(optionList)

    def add_user(self, form):
        field_names = {
            'realName': 'Full Name',
            'tel': 'Telephone',
            'email': 'Email'
        }
        values = {'%USERNAME%' : form.get('userid', ''),
                  '%FULLNAME%' : form.get('realName', ''),
                  '%EMAIL%' : form.get('email', ''),
                  '%TELEPHONE%' : form.get('tel', '')
                  }
        if (form.get('submit', None)):
            userid = form.get('userid', None)
            if userid:
                userid = userid.value
            usertype = form.get('usertype', 'user')
            if not (userid and userid.isalnum()):
                if not userid:
                    message = ('Unable to add user - '
                               'you MUST supply a username'
                               )
                else:
                    message = ('Unable to add user - username may include '
                               'only alphanumeric characters.'
                               )
                values['%USERNAME%'] = ''
                values['%USER%'] = ''
                values['%SUPERUSER%'] = 'checked="checked"'
                return self.show_adminMenu(
                    values,
                    '<p class="error">{0}</p>'.format(message)
                )
            try:
                user = userStore.fetch_object(session, userid)
            except c3errors.ObjectDoesNotExistException:
                user = None
            if user is not None:
                values['%USERNAME%'] = ''
                values['%USER%'] = ''
                values['%SUPERUSER%'] = 'checked="checked"'
                return self.show_adminMenu(
                    values,
                    '<p class="error">User with username/id "{0}" already '
                    'exists! Please try again with a different username.</p>'
                    ''.format(userid)
                )
            else:
                # we do want to add this user
                if (usertype == 'superuser'):
                    userDoc = StringDocument(
                        new_adminuser_template.replace('%USERNAME%', userid)
                    )
                    userRec = xmlp.process_document(session, userDoc)
                    values['%SUPERUSER%'] = 'checked="checked"'
                    values['%USER%'] = ''
                else:
                    userDoc = StringDocument(
                        new_user_template.replace('%USERNAME%', userid)
                    )
                    userRec = xmlp.process_document(session, userDoc)
                    values['%USER%'] = 'checked="checked"'
                    values['%SUPERUSER%'] = ''
                userNode = userRec.get_dom(session)
                newHash = {}
                for f in session.user.simpleNodes:
                    if form.has_key(f):
                        newHash[f] = form.getfirst(f)
                        if not newHash[f] and f != 'tel':
                            return self.show_adminMenu(
                                values,
                                '<p class="error">Unable to add user. '
                                '{0} not supplied.</p>'
                                ''.format(field_names.get(f, f))
                            )
                passwd = form.get('passwd', None)
                # Check password
                passwd1 = form.get('passwd1', None)
                if (passwd1 and passwd1 != ''):
                    passwd2 = form.get('passwd2', None)
                    if (passwd1 == passwd2):
                        newHash['password'] = crypt(passwd1, passwd1[:2])
                    else:
                        return self.show_adminMenu(
                            values,
                            '<p class="error">Unable to add user. '
                            'Passwords did not match.</p>'
                        )
                else:
                    return self.show_adminMenu(
                        values,
                        '<p class="error">Unable to add user. '
                        'Password not supplied.</p>'
                    )
                # Institution
                inst = form.get('institutionSelect', None)
                if inst == None or inst == 'null':
                    return self.show_adminMenu(
                        values,
                        '<p class="error">Unable to add user. '
                        'Institution not supplied.</p>'
                    )
                # Update DOM
                userNode = self._modify_userLxml(userNode, newHash)
                self._submit_userLxml(userid, userNode)
                # Need to fetch user as record in order for link function to
                # work
                user = userStore.fetch_record(session, userid)
                userStore.link(session,
                               'linkAuthInst',
                               user,
                               institutionId=inst.value
                               )
                values['%USERNAME%'] = ''
                values['%FULLNAME%'] = ''
                values['%EMAIL%'] = ''
                values['%TELEPHONE%'] = ''
                values['%USER%'] = ''
                values['%SUPERUSER%'] = 'checked="true"'
                return self.show_adminMenu(
                    values,
                    message='<p class="ok">User added.</p>'
                )
        return self.show_adminMenu(values)
        #- end add_user()

    def delete_user(self, form):
        global userStore, rebuild
        userid = form.get('user', None)
        cancel = form.get('cancel', None)
        confirm = form.get('confirm', None)
        passwd = form.get('passwd', None)
        if (confirm == 'true'):
            output = [
                '<div id="single"><h3 class="bar">Delete User Confirmation.'
                '</h3>',
                read_file('deleteuser.html').replace('%USERID%', userid),
                '</div>'
            ]
            return ''.join(output)
        elif (cancel == 'Cancel'):
            return self.show_adminMenu(
                None,
                '<p class="error">Delete cancelled at your request.</p>'
            )
        else:
            if (passwd and session.user.check_password(session, passwd)):
                try:
                    userStore.delete_record(session, userid)
                except:
                    return self.show_adminMenu(
                        None,
                        '<p class="error">Unable to delete user {0} - '
                        'user does not exist.</p>'.format(userid)
                    )
                else:
                    rebuild = True
                    return self.show_adminMenu(
                        None,
                        '<p class="ok">User {0} Deleted.</p>'.format(userid)
                    )
            else:
                return self.show_adminMenu(
                    None,
                    '<p class="error">Unable to delete user {0} - '
                    'incorrect password.</p>'
                    ''.format(userid)
                )
        #- end delete_user()

    def _modify_userLxml(self, userNode, updateHash):
        for c in userNode.iterchildren(tag=etree.Element):
            if c.tag in updateHash:
                c.text = updateHash.pop(c.tag)

        for k,v in updateHash.iteritems():
            el = etree.SubElement(userNode, k)
            el.text = v

        return userNode
        #- end _modify_userLxml()

    def _submit_userLxml(self, id, userNode):
        rec = LxmlRecord(userNode)
        rec.id = id
        userStore.store_record(session, rec)
        userStore.commit_storing(session)
        #- end _submit_userLxml()

    def add_inst(self, form):
        global instStore
        inst = form.get('institution', None)
        quota = form.get('quota', '50')
        docstr = ('<inst><name>{0}</name><quota>{1}</quota></inst>'
                  ''.format(inst, quota)
                  )
        if inst is not None:
            doc = StringDocument(docstr)
            rec = xmlp.process_document(session, doc)
            _ = instStore.create_record(session, rec)
            return self.show_adminMenu()
        else:
            return self.show_adminMenu()

    def edit_inst(self, form):
        id = form.get('id', None)
        inst = form.get('institution', None)
        quota = form.get('quota', '50')
        print id, inst, quota
        docstr = ('<inst><name>{0}</name><quota>{1}</quota></inst>'
                  ''.format(inst, quota)
                  )
        if inst is not None:
            doc = StringDocument(docstr)
            rec = xmlp.process_document(session, doc)
            rec.id = id
#             instStore.delete_record(session, id)
            instStore.store_record(session, rec)
            return self.show_adminMenu()
        else:
            return self.show_adminMenu()

    def delete_inst(self, form):
        global instStore, rebuild
        instid = form.get('inst', None)
        cancel = form.get('cancel', None)
        confirm = form.get('confirm', None)
        passwd = form.get('passwd', None)
        #check again to see that this inst has no users.
        sqlQ = ("SELECT hubAuthStore FROM hubAuthStore_linkauthinst WHERE "
                "institutionid=%s"
                )
        result = userStore._query(sqlQ, (instid,))
        if len(result):
            return self.show_adminMenu(
                None,
                '<p class="error">Unable to delete institution - '
                'there are still {0} users in this institution which must be '
                'deleted first.</p>'.format(len(result))
            )

        if (confirm == 'true'):
            sqlQ = ("SELECT editingstore FROM editingstore_linkrecinst WHERE "
                    "institutionid=%s"
                    )
            result = userStore._query(sqlQ, (instid,))
            if len(result):
                fileinfo = ('<b>This institution still has draft files '
                            'linked to it - if you delete this institution '
                            'the draft files linked to it will also be '
                            'deleted</b>'
                            )
                output = ['<div id="single"><h3 class="bar">Delete '
                          'Institution Confirmation.</h3>',
                          multiReplace(read_file('deleteinst.html'),
                                       dict(['%INSTID%', instid,
                                             '%%%FILEINFO%%%', fileinfo
                                             ])
                          ),
                          '</div>'
                          ]
            else:
                output = ['<div id="single">',
                          '<h3 class="bar">',
                          'Delete Institution Confirmation.',
                          '</h3>',
                          multiReplace(read_file('deleteinst.html'),
                                       dict([('%INSTID%', instid),
                                             ('%%%FILEINFO%%%', '')
                                             ])
                                       ),
                          '</div>'
                          ]
            return ''.join(output)
        elif (cancel == 'Cancel'):
            return self.show_adminMenu()
        else:
            if (passwd and session.user.check_password(session, passwd)):
                try:
                    instStore.delete_record(session, instid)
                except:
                    return self.show_adminMenu(
                        None,
                        '<p class="error">Unable to delete institution - '
                        'user does not exist.</p>'
                    )
                else:
                    sqlQ = ("SELECT editingstore FROM "
                            "editingstore_linkrecinst WHERE institutionid=%s"
                            )
                    result = userStore._query(sqlQ, (instid,))
                    for r in result:
                        recid = r['editingstore']
                        try:
                            editStore.delete_record(session, recid)
                        except:
                            pass
                    rebuild = True
                    return self.show_adminMenu()
            else :
                return self.show_adminMenu(
                    None,
                    '<p class="error">Unable to delete institution - '
                    'incorrect password.</p>'
                )
        #- end delete_user()

    def get_contactDetails(self, form):
        un = form.get('un', None)
        if un != None:
            try:
                user = userStore.fetch_object(session, un)
            except:
                return '<p>There is no user with that username</p>'
            else:
                return '''<table>
                            <tr><td>Full Name: </td><td>%s</td></tr>
                            <tr><td>Email: </td><td>%s</td></tr>
                            <tr><td>Telephone: </td><td>%s</td></tr>
                        </table>''' % (user.realName, user.email, user.tel)

    def handle(self, req):
        form = FieldStorage(req, True)
        tmpl = unicode(read_file(self.baseTemplatePath))
        title = ' :: '.join(self.htmlTitle)
        navbar = ' '.join(self.htmlNav)
        tmpl = tmpl.replace("%TITLE%", title).replace("%NAVBAR%", navbar)
        path = req.uri[1:]
        path = path[path.rfind('/') + 1:]
        content = None
        operation = form.get('operation', None)
        if path.endswith('.js'):
            self.send_response(read_file(abspath('../js/{0}'.format(path))),
                               req,
                               content_type='text/javascript',
                               code=200
                               )
            return apache.OK
        elif path == 'users.html':
            if (operation):
                if (operation == 'findcontacts'):
                    content = self.get_contactDetails(form)
                    self.send_xml(content, req)
                    return
                else:
                    if (operation == 'adduser'):
                        content = self.add_user(form)
                    elif (operation == 'addinstitution'):
                        content = self.add_inst(form)
                    elif (operation == 'editinstitution'):
                        content = self.edit_inst(form)
                    elif (operation == 'deleteinst'):
                        content = self.delete_inst(form)
                    elif (operation == 'deleteuser'):
                        content = self.delete_user(form)
                    elif operation in ['edit', 'edituser']:
                        content = self.edit_user(form)
                    else:
                        content = self.show_adminMenu()
            else:
                content = self.show_adminMenu()
        elif path == 'admin':
            # redirect to make sure later relative links work correctly
            redirect(req, 'admin/',
                     permanent=False, # TODO: make me True
                     text=("To prevent URL collisions caused by internal "
                           "relative, this service must be accessed at "
                           "admin/"
                           )
                     )
        else:
            content = self.show_adminMenu()
        content = tmpl.replace('%CONTENT%', content)
        # send the display
        self.send_html(content, req)


def build_architecture(data=None):
    global rebuild, session, serv, db, dbPath
    global editStore, authStore, instStore, userStore, xmlp

    session = Session()
    session.database = 'db_hubedit'
    session.environment = 'apache'
    # session.user = None
    serv = SimpleServer(session,
                        os.path.join(cheshire3Root,
                                     'configs',
                                     'serverConfig.xml'
                                     )
                        )
    db = serv.get_object(session, 'db_hubedit')

    dbPath = db.get_path(session, 'defaultPath')

    editStore = db.get_object(session, 'editingStore')
    userStore = db.get_object(session, 'hubAuthStore')
    instStore = db.get_object(session, 'institutionStore')

    authStore = db.get_object(session, 'adminAuthStore')
    xmlp = db.get_object(session, 'LxmlParser')

    rebuild = False


def handler(req):
    global rebuild, logfilepath, cheshirePath
    global db, editStore, xmlp, formTxr, script
    script = req.subprocess_env['SCRIPT_NAME']
    req.register_cleanup(build_architecture)
    if (rebuild):
        # Build the architecture
        build_architecture()
    session.user = authStore.fetch_object(session, req.user)
    try:
        # Get the remote host's IP
        remote_host = req.get_remote_host(apache.REMOTE_NOLOOKUP)
        # initialise logger object
        lgr = FileLogger(
            os.path.join(cheshirePath,
                         'www',
                         'hubedit',
                         'logs',
                         'adminhandler.log'
                         ),
            remote_host
        )
        # initialise handler - with logger for this request
        hubeditAdminHandler = HubeditAdminHandler(lgr)
        # cd to where html fragments are
        os.chdir(hubeditAdminHandler.templatePath)
        # handle request
        try:
            hubeditAdminHandler.handle(req)
        finally:
            try:
                lgr.flush()
            except:
                pass
            del lgr, hubeditAdminHandler
    except:
        req.content_type = "text/html"
        # give error info
        cgitb.Hook(file = req).handle()
        return apache.HTTP_INTERNAL_SERVER_ERROR
    else:
        return apache.OK


def check_password(username, password):
    global session, authStore, rebuild
    if (rebuild):
        # Build the architecture
        build_architecture()
    try:
        u = session.user = authStore.fetch_object(session, username)
    except c3errors.ObjectDoesNotExistException:
        return None
    if u.check_password(session, password):
        return True
    else:
        return False


def authenhandler(req):
    pw = req.get_basic_auth_pw()
    un = req.user
    result = check_password(un, pw)
    if result:
        return apache.OK
    return apache.HTTP_UNAUTHORIZED
    #- end authenhandler()


rebuild = True
serv = None
session = None
db = None
editStore = None
authStore = None
xmlp = None
