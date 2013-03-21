#!/bin/env python
#
# Script:    users.py
# Date:      20 March 2013
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


from cheshire3.baseObjects import Session
from cheshire3.exceptions import ObjectDoesNotExistException
from cheshire3.server import SimpleServer

from cheshire3.commands.cmd_utils import identify_database

from cheshire3archives.commands.utils import BaseArgumentParser


class UsersArgumentParser(BaseArgumentParser):
    """Custom option parser for Cheshire3 for Archives management."""
    
    def __init__(self, *args, **kwargs):
        BaseArgumentParser.__init__(self, *args, **kwargs)
        self.add_argument('-d', '--database',
                  type=str, action='store', dest='database',
                  default=None, metavar='DATABASE',
                  help="identifier of Cheshire3 database")


def add_user(args):
    return 0


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
parser_add.add_argument('username',
                        type=str,
                        nargs='*',
                        help='Username of the user to add')
parser_add.set_defaults(func=add_user)
# Create the parser for the "remove" command
parser_remove = subparsers.add_parser('remove',
                                      help='Remove an existing user')
parser_remove.add_argument('username',
                           type=str,
                           nargs='*',
                           help='Username of the user to remove')
parser_remove.set_defaults(func=remove_user)


if __name__ == '__main__':
    sys.exit(main())
