#!/bin/env python
#
# Script:    run.py
# Date:      3 September 2010
# Copyright: &copy; University of Liverpool 2005-2010
# Description:
#            script to establish environment for Cheshire3 EAD Editor.
#
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
#            CS - Catherine Smith
#
# Language:  Python
#
"""Interact with the Archives Hub EAD Editor database.

Usage: run.py [OPTION]

Options:

 -h, -?    --help, --options    Print help and exit
 -s        --addsuperuser       Add a new superuser

"""

import getopt
import os
import re
import sys
import time
import traceback

from crypt import crypt
from getpass import getpass


cheshirePath = os.environ.get('C3HOME', '/home/cheshire/')
sys.path.insert(1, os.path.join(cheshirePath, 'cheshire3', 'code'))

from cheshire3.baseObjects import Session
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.document import StringDocument
from cheshire3 import exceptions as c3errors

from cheshire3.web.www_utils import read_file

debug = False

# import customisable variables
#from localConfig import *


class Error(Exception):
    """Base class for exceptions in this module.

    Attributes:
        msg  -- explanation of the error
    """

    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return repr(self.msg)


class UsageError(Error):
    """Exception raised for errors in use of the script and its options."""
    pass


class InputError(Error):
    """Exception raised for errors in the input."""
    pass


class InputMissingError(InputError):
    """Exception raised for errors relating to missing input."""
    pass


class InputIncorrectError(Error):
    """Exception raised for errors relating to incorrect input."""
    pass


class DatabaseOperationError(Error):
    """Exception raised when database operations do not go as intended."""
    pass


def getUserInfoFromPrompt():
    userInfo = {}
    un = raw_input('Please enter a username: ')
    if not un:
        raise InputMissingError('You must enter a username for this user.')
    userInfo['username'] = un
    pw = getpass('Please enter a password for this user: ')
    if not (pw and len(pw)):
        raise InputMissingError('You must enter a password for this user.')
    pw2 = getpass('Please re-enter the password to confirm: ')
    if pw != pw2:
        raise InputIncorrectError('The two passwords submitted did not '
                                  'match. Please try again.'
                                  )
    else:
        userInfo['password'] = crypt(pw, un[:2])
    userInfo['realName'] = raw_input(
        'Real name of this user (not mandatory): '
    )
    userInfo['email'] = raw_input(
        'Email address for this user (not mandatory): '
    )
    return userInfo


def addSuperUser(userInfo={}):
    if not all(
        userInfo,
        'username' in userInfo,
        userInfo['username']
    ):
        userInfo = getUserInfoFromPrompt()
    xml = read_file('admin.xml')
    xml = xml.replace('%USERNAME%', userInfo.pop('username'))
    for k, v in userInfo.iteritems():
        placeholder = "%{0}%".format(k)
        if v and len(v):
            xml = xml.replace(placeholder, '\n  <{0}>{1}</{0}>'.format(k, v))
        else:
            xml = xml.replace(placeholder, '')
    doc = StringDocument(xml)
    rec = xmlp.process_document(session, doc)
    id = rec.process_xpath(session, '/config/@id')[0]
    rec.id = id
    superAuthStore.store_record(session, rec)
    superAuthStore.commit_storing(session)
    # Confirm user stored
    try:
        user = superAuthStore.fetch_object(session, id)
    except c3errors.ObjectDoesNotExistException:
        raise DatabaseOperationError(
            'User not successfully created. Please try again.'
        )
    print 'OK: Username and passwords set for this user'
    return 0


def parseArgs(argv):
    if argv is None:
        argv = sys.argv
    try:
        return getopt.getopt(argv[1:],
                             "?h",
                             ["help", "options", "addsuperuser"]
                             )
    except getopt.error, msg:
        raise UsageError(msg)


def main(argv=None):
    try:
        opts, args = parseArgs(argv)
        for o, a in opts:
            if (o in ['-?', '-h', '--help', '--options']):
                print __doc__
                return 0
            elif (o == '--addsuperuser'):
                return addSuperUser()
    except UsageError as err:
        sys.stderr.write(str(err) + '\n')
        sys.stderr.write("for help use --help\n")
        sys.stderr.flush()
        return 2
    except Error as e:
        lgr.log_lvl(session, 40, str(e))
        if debug:
            raise
        return 1


# Build environment...
session = Session()
serv = SimpleServer(
    session,
    os.path.join(cheshire3Root,
                 'configs',
                 'serverConfig.xml'
                 )
)
session.database = 'db_hubedit'

db = serv.get_object(session, 'db_hubedit')
lgr = db.get_path(session, 'defaultLogger')
authStore = db.get_object(session, 'hubAuthStore')
superAuthStore = db.get_object(session, 'hubSuperAuthStore')

xmlp = db.get_object(session, 'LxmlParser')

if __name__ == "__main__":
    sys.exit(main())
