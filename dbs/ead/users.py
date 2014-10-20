#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Script:    users.py
# Copyright: &copy; University of Liverpool 2005-present
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Manage Cheshire3 for Archives admin users.

Manage users of the Cheshire3 for Archives EAD finding aid document database
administration console.
"""

import os
import sys

from crypt import crypt
from getpass import getpass

from cheshire3.baseObjects import Session
from cheshire3.exceptions import ObjectDoesNotExistException
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.document import StringDocument

from cheshire3.commands.cmd_utils import identify_database

from archiveshub.deploy.utils import BaseArgumentParser


USER_TEMPLATE = """
<config type="user" id="%USERNAME%">
  <objectType>cheshire3.user.SimpleUser</objectType>
  <username>%USERNAME%</username>
  %password% %realName% %email%
  <flags>
    <flag>
      <object/>
      <value>c3r:administrator</value>
    </flag>
  </flags>
</config>
"""


class UsersArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""

    def __init__(self, *args, **kwargs):
        BaseArgumentParser.__init__(self, *args, **kwargs)
        self.add_argument('-d', '--database',
                  type=str, action='store', dest='database',
                  default=None, metavar='DATABASE',
                  help="identifier of Cheshire3 database")


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


def getUserInfoFromPrompt(args):
    """Get and return user info by prompting user."""
    userInfo = {}
    if not args.username:
        args.username = raw_input('Please enter a username: ')
        if not args.username:
            raise InputMissingError('You must enter a username for this '
                                    'user.'
                                    )
    userInfo['username'] = args.username
    pw = getpass('Please enter a password for this user: ')
    if not (pw and len(pw)):
        raise InputMissingError('You must enter a password for this user.')
    pw2 = getpass('Please re-enter the password to confirm: ')
    if pw != pw2:
        raise InputIncorrectError('The two passwords submitted did not '
                                  'match. Please try again.'
                                  )
    else:
        userInfo['password'] = crypt(pw, args.username[:2])
    userInfo['realName'] = raw_input(
        'Real name of this user: '
    )
    if not userInfo['realName']:
        raise InputMissingError('You must enter a real name for this user.')
    userInfo['email'] = raw_input(
        'Email address for this user: '
    )
    if not userInfo['email']:
        raise InputMissingError('You must enter an email address for this user'
                                '.'
                                )
    return userInfo


def add_superUser(args):
    global USER_TEMPLATE
    userInfo = getUserInfoFromPrompt(args)
    xml = USER_TEMPLATE.replace('%USERNAME%', userInfo.pop('username'))
    for k, v in userInfo.iteritems():
        placeholder = "%{0}%".format(k)
        if v and len(v):
            xml = xml.replace(placeholder, '\n  <{0}>{1}</{0}>'.format(k, v))
        else:
            xml = xml.replace(placeholder, '')
    doc = StringDocument(xml)
    rec = xmlp.process_document(session, doc)
    id_ = rec.process_xpath(session, '/config/@id')[0]
    rec.id = id_
    superAuthStore.store_record(session, rec)
    superAuthStore.commit_storing(session)
    # Confirm user stored
    try:
        _ = superAuthStore.fetch_object(session, id_)
    except ObjectDoesNotExistException:
        raise DatabaseOperationError(
            'User not successfully created. Please try again.'
        )
    session.logger.log_info(
        session,
        'OK: Username and passwords set for this user'
    )
    return 0


def add_user(args):
    global session
    if args.super:
        return add_superUser(args)
    else:
        session.logger.log_critical(
            session,
            "Creating Editor users not yet supported."
        )
        return 1


def list_users(args):
    global superAuthStore, authStore
    if args.super:
        for user in superAuthStore:
            print user.username
    else:
        institutions = []
        for instRec in instStore:
            instName = instRec.process_xpath(session, '//name/text()')[0]
            institutions.append((instName, instRec))
        for instName, instRec in sorted(institutions):
            sqlQ = ("SELECT hubAuthStore FROM hubAuthStore_linkauthinst "
                    "WHERE institutionid=%s ORDER BY hubAuthStore"
                    )
            result = authStore._query(sqlQ, (instRec.id,))
            quota = instRec.process_xpath(session, '//quota/text()')[0]
            print '{0} {{{1}}}'.format(instName, quota)
            if len(result):
                for r in result:
                    print '\t{0}'.format(*r)



def remove_user(args):
    return 0


def main(argv=None):
    global argparser, lockfilepath, lgr
    global session, server, db, lgr
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    session = Session()
    server = SimpleServer(session, args.serverconfig)
    if args.database is None:
        try:
            dbid = identify_database(session, os.getcwd())
        except EnvironmentError as e:
            server.log_critical(session, e.message)
            return 1
        server.log_debug(
            session, 
            "database identifier not specified, discovered: {0}".format(dbid))
    else:
        dbid = args.database

    try:
        db = server.get_object(session, dbid)
    except ObjectDoesNotExistException:
        msg = """Cheshire3 database {0} does not exist.
Please provide a different database identifier using the --database option.
""".format(dbid)
        server.log_critical(session, msg)
        return 2
    else:
        lgr = db.get_path(session, 'defaultLogger')
        pass
    return args.func(args)


# Init Argument Parser
docbits = __doc__.split('\n\n')
argparser = UsersArgumentParser(conflict_handler='resolve',
                                description=docbits[0]
                               )
subparsers = argparser.add_subparsers(title='Actions')
# Create the parser for the "add" command
parser_add = subparsers.add_parser('add',
                                   help='Add a new user')
parser_add.add_argument('-a', '--admin',
                        action='store_true',
                        dest='super',
                        help="Create an administrative user"
                        )
parser_add.add_argument('username',
                        type=str,
                        help='Username of the user to add')
parser_add.set_defaults(func=add_user)
# Create the parser for the "list" command
parser_list = subparsers.add_parser('list',
                                    help='List existing users')
parser_list.add_argument('-a', '--admin',
                         action='store_true',
                         dest='super',
                         help="List administrative users"
                        )
parser_list.set_defaults(func=list_users)

# Create the parser for the "remove" command
parser_remove = subparsers.add_parser('remove',
                                      help='Remove an existing user')

parser_remove.add_argument('username',
                           type=str,
                           nargs='*',
                           help='Username of the user(s) to remove')
parser_remove.set_defaults(func=remove_user)


# Build environment...
session = Session()
serv = SimpleServer(
    session,
    os.path.join(cheshire3Root,
                 'configs',
                 'serverConfig.xml'
                 )
)
session.database = 'db_ead'
db = serv.get_object(session, 'db_ead')
xmlp = db.get_object(session, 'LxmlParser')
authStore = db.get_object(session, 'hubAuthStore')          # Editors
superAuthStore = db.get_object(session, 'adminAuthStore')   # Hub Staff
instStore = db.get_object(session, 'institutionStore')      # Institutions


if __name__ == '__main__':
    sys.exit(main())
