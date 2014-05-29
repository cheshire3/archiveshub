"""Setuptools command sub-classes."""
from __future__ import with_statement

import os
import re
import sys
import shutil
import inspect

from os.path import expanduser, abspath, dirname, join, exists, islink
from pkg_resources import normalize_path

from setuptools import Command
from setuptools.command import develop as _develop
from setuptools.command import install as _install

from cheshire3.exceptions import ConfigFileException
from cheshire3.internal import cheshire3Home, cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.session import Session

from archiveshub.setuptools.apache import ApacheModifier
from archiveshub.setuptools.exceptions import *


class unavailable_command(Command):
    """Sub-class commands that we don't want to make available."""

    description = "Command is not appropriate for this package"
    user_options = []
    boolean_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        raise NotImplementedError(self.description)


class c3_command(Command):
    """Base Class for custom commands."""

    user_options = [
        ("with-httpd=",
         None,
         "Set the path to Apache HTTPD installation directory"),
    ]

    def initialize_options(self):
        self.with_httpd = None

    def finalize_options(self):
        if self.with_httpd is not None:
            self.with_httpd = normalize_path(expanduser(self.with_httpd))

    def install_apache_mods(self, develop=False):
        """Install Apache HTTPD modifications."""
        # Install Apache HTTPD configuration plugin file
        am = ApacheModifier(self.with_httpd, develop)
        try:
            am.install_apache_config()
        except IOError as e:
            if e.strerror == "Permission denied":
                # Permission to modify Apache denied
                raise IOError(e.errno,
                              "Permission denied\n\n"
                              "The following error occurred while trying to "
                              "add or remove files in the installation "
                              "directory:\n\n    " +
                              str(e) +
                              "\n\nThe Apache installation directory you "
                              "specified (via --with-httpd or the default "
                              "setting) was:\n\n    " +
                              self.with_httpd +
                              "\n\nPerhaps your account does not have write "
                              "access to this directory?  If the installation "
                              "directory is a system-owned directory, you may "
                              "need to sign in as the administrator or "
                              "\"root\" account.\n\n"
                              "HINT: you could try running\n\n    "
                              "su -c \"python setup.py %s\""
                              "" % self.__class__.__name__,
                              e.filename)
            else:
                raise e

    def uninstall_apache_mods(self):
        # Uninstall Apache HTTPD configuration plugin file
        am = ApacheModifier(self.with_httpd)
        try:
            am.uninstall_apache_config()
        except IOError as e:
            if e.strerror == "Permission denied":
                # Permission to modify Apache denied
                raise IOError(e.errno,
                              "Permission denied\n\n"
                              "The following error occurred while trying to "
                              "add or remove files in the installation "
                              "directory:\n\n    " +
                              str(e) +
                              "\n\nThe Apache installation directory you "
                              "specified (via --with-httpd or the default "
                              "setting) was:\n\n    " +
                              self.with_httpd +
                              "\n\nPerhaps your account does not have write "
                              "access to this directory?  If the installation "
                              "directory is a system-owned directory, you may "
                              "need to sign in as the administrator or "
                              "\"root\" account.\n\n"
                              "HINT: you could try running\n\n    "
                              "su -c \"python setup.py %s\""
                              "" % self.__class__.__name__,
                              e.filename)
            else:
                raise e

    def apply_config_templates(self):
        """Read config template(s), make subs, write config file(s)."""
        global distropath

        def apply_config_tmpl(path):
            "Subroutine to turn templates into configs"
            global distropath
            # Read in template
            with open(path + '.tmpl', 'r') as fh:
                config = fh.read()
            # Make replacements
            config = re.sub('type="defaultPath">~/archiveshub/(.*?)</',
                            r'type="defaultPath">{0}/\1</'.format(distropath),
                            config
                            )
            # Write finished config file
            with open(path, 'w') as fh:
                fh.write(config)

        # EAD Database
        apply_config_tmpl(join(distropath,
                               'dbs',
                               'ead',
                               'config.xml')
                          )
        # EAD Cluster Database
        apply_config_tmpl(join(distropath,
                               'dbs',
                               'ead',
                               'cluster',
                               'config.xml')
                          )
        from archiveshub.apps.configuration import config
        with open(join(distropath, 'www', 'ead', 'ead.ini'), 'w') as fh:
            config.write(fh)


class develop(_develop.develop, c3_command):

    user_options = _develop.develop.user_options + c3_command.user_options

    def initialize_options(self):
        _develop.develop.initialize_options(self)
        c3_command.initialize_options(self)

    def finalize_options(self):
        _develop.develop.finalize_options(self)
        c3_command.finalize_options(self)

    def install_for_development(self):
        global distropath, server, session
        # Carry out normal procedure
        _develop.develop.install_for_development(self)
        # Use config templates to generate configs
        self.apply_config_templates()
        # Tell the server to register the config file
        try:
            server.register_databaseConfigFile(session, join(distropath,
                                                             'dbs',
                                                             'ead',
                                                             'config.xml'))
        except ConfigFileException as e:
            if e.reason.startswith("Database with id 'db_ead' is already "
                                   "registered."):
                # Existing install / development install
                raise DevelopException("Package is already installed. To "
                                       "install in 'develop' mode you must "
                                       "first run the 'uninstall' command.")
        else:
            server.register_databaseConfigFile(session, join(distropath,
                                                             'dbs',
                                                             'ead',
                                                             'cluster',
                                                             'config.xml'))
        # New version runs from unpacked / checked out directory
        # No need to install database or web app
        if self.with_httpd is not None:
            # Install Apache HTTPD mods
            self.install_apache_mods(develop=True)

    def uninstall_link(self):
        global server, session
        # Carry out normal procedure
        _develop.develop.uninstall_link(self)
        if self.with_httpd is not None:
            # Uninstall Apache HTTPD mods
            self.uninstall_apache_mods()
        # Unregister the database by deleting
        # Cheshire3 database config plugin
        serverDefaultPath = server.get_path(session,
                                            'defaultPath',
                                            cheshire3Root)
        userSpecificPath = join(expanduser('~'), '.cheshire3-server')
        pluginPath = os.path.join('configs', 'databases', 'db_ead.xml')
        if exists(join(serverDefaultPath, pluginPath)):
            os.remove(join(serverDefaultPath, pluginPath))
            os.remove(join(serverDefaultPath,
                           'configs',
                           'databases',
                           'db_ead_cluster.xml'))
        elif exists(os.path.join(userSpecificPath, pluginPath)):
            os.remove(os.path.join(userSpecificPath, pluginPath))
            os.remove(join(userSpecificPath,
                           'configs',
                           'databases',
                           'db_ead_cluster.xml'))
        else:
            server.log_error(session, "No database plugin file")


class install(_install.install, c3_command):

    user_options = _install.install.user_options + c3_command.user_options

    def initialize_options(self):
        _install.install.initialize_options(self)
        c3_command.initialize_options(self)

    def finalize_options(self):
        _install.install.finalize_options(self)
        c3_command.finalize_options(self)

    def run(self):
        # Carry out normal procedure
        _install.install.run(self)
        # Use config templates to generate configs
        self.apply_config_templates()
        # Install Cheshire3 database config plugin
        # Tell the server to register the config file
        try:
            server.register_databaseConfigFile(session, join(distropath,
                                                             'dbs',
                                                             'ead',
                                                             'config.xml'))
        except ConfigFileException as e:
            if e.reason.startswith("Database with id 'db_ead' is already "
                                   "registered."):
                # Existing install / development install
                raise InstallException("Package is already installed. To "
                                       "install you must first run the "
                                       "'uninstall' command.")
        else:
            server.register_databaseConfigFile(session, join(distropath,
                                                             'dbs',
                                                             'ead',
                                                             'cluster',
                                                             'config.xml'))
        # New version runs from unpacked / checked out directory
        # No need to install database or web app
        if self.with_httpd is not None:
            # Install Apache HTTPD mods
            self.install_apache_mods()


class upgrade(_install.install, c3_command):
    # Extremely experimental and untested...

    user_options = _install.install.user_options + c3_command.user_options

    def initialize_options(self):
        _install.install.initialize_options(self)
        c3_command.initialize_options(self)

    def finalize_options(self):
        _install.install.finalize_options(self)
        c3_command.finalize_options(self)

    def run(self):
        # Carry out normal procedure
        _install.install.run(self)
        # Use config templates to generate configs
        self.apply_config_templates()
        # Upgrade database directory
        subpath = join('cheshire3',
                       'dbs',
                       'ead')
        shutil.copytree(join(distropath, 'dbs', 'ead'),
                        join(cheshire3Home, subpath),
                        symlinks=False,
                        ignore=shutil.ignore_patterns(".git*",
                                                      "*.pyc",
                                                      "PyZ3950_parsetab.py*",
                                                      "*.bdb",
                                                      "*.log")
                        )
        # Upgrade to web app directory
        subpath = join('cheshire3',
                       'www',
                       'ead'
                       )
        shutil.copytree(join(distropath, 'www'),
                        join(cheshire3Home, subpath),
                        symlinks=False,
                        ignore=shutil.ignore_patterns(".git*",
                                                      "*.pyc",
                                                      "PyZ3950_parsetab.py*",
                                                      "*.bdb",
                                                      "*.log"
                                                      )
                        )
        if self.with_httpd is not None:
            # Install Apache HTTPD mods
            self.install_apache_mods()


class uninstall(c3_command):

    description = "Uninstall Cheshire3 for Archives"

    def run(self):
        if self.with_httpd is not None:
            # Uninstall Apache HTTPD mods
            self.uninstall_apache_mods()
        # Unregister the database by deleting
        # Cheshire3 database config plugin
        serverDefaultPath = server.get_path(session,
                                            'defaultPath',
                                            cheshire3Root)
        userSpecificPath = join(expanduser('~'), '.cheshire3-server')
        pluginPath = os.path.join('configs', 'databases', 'db_ead.xml')
        if exists(join(serverDefaultPath, pluginPath)):
            os.remove(join(serverDefaultPath, pluginPath))
            os.remove(join(serverDefaultPath,
                           'configs',
                           'databases',
                           'db_ead_cluster.xml'))
        elif exists(os.path.join(userSpecificPath, pluginPath)):
            os.remove(os.path.join(userSpecificPath, pluginPath))
            os.remove(join(userSpecificPath,
                           'configs',
                           'databases',
                           'db_ead_cluster.xml'))
        else:
            server.log_error(session, "No database plugin file")


# Inspect to find current path
modpath = inspect.getfile(inspect.currentframe())
moddir = dirname(modpath)
distropath = abspath(join(moddir, '..', '..'))
serverConfig = os.path.join(cheshire3Root,
                            'configs',
                            'serverConfig.xml')
session = Session()
server = SimpleServer(session, serverConfig)
