"""Setuptools command sub-classes."""

import os
import inspect

from os.path import abspath, dirname, join, exists, expanduser

from setuptools import Command
from setuptools.command import develop as _develop
from setuptools.command import install as _install

from apache import ApacheModifier

class unavailable_command(Command):
    """Sub-class commands that we don't want to make available."""

    description = "Command is not appropriate for this package"
    user_options = []
    boolean_options = []

    def initialize_options(self):
        raise NotImplementedError(self.description)

    def finalize_options(self):
        raise NotImplementedError(self.description)

    def run(self):
        raise NotImplementedError(self.description)


class develop(_develop.develop):
    
    user_options = _develop.develop.user_options + [
        ("with-httpd=", None, "Set the path to Apache HTTPD installation directory"),
    ]
    
    def initialize_options(self):
        _develop.develop.initialize_options(self)
        from cheshire3.internal import cheshire3Home
        self.with_httpd = join(cheshire3Home, 'install')

    def finalize_options(self):
        _develop.develop.finalize_options(self)

    def run(self):
        global distropath
        # Carry out normal procedure
        _develop.develop.run(self)
        # Install Apache HTTPD configuration stub file
        am = ApacheModifier(expanduser(self.with_httpd))
        am.install_apache_config()
        # Create web directory for static search pages
        # and install default landing page there
        am.install_web_landing_page()
        # Create symbolic links
        from cheshire3.internal import cheshire3Home
        # Link to Cheshire3 database config stub
        os.symlink(join(distropath,
                                'cheshire3', 
                                'dbs', 
                                'configs.d', 
                                'db_ead.xml'), 
                   join(cheshire3Home, 
                                'cheshire3', 
                                'dbs', 
                                'configs.d', 
                                'db_ead.xml')
                   )
        # Link to database directory
        os.symlink(join(distropath,
                        'cheshire3', 
                        'dbs', 
                        'ead'), 
                   join(cheshire3Home, 
                        'cheshire3', 
                        'dbs', 
                        'ead')
                   )
        # Link to web app directory
        os.symlink(join(distropath,
                        'cheshire3', 
                        'www', 
                        'ead'), 
                   join(cheshire3Home, 
                        'cheshire3', 
                        'www', 
                        'ead')
                   )
        

class install(_install.install):
    def initialize_options(self):
        _install.install.initialize_options(self)

    def finalize_options(self):
        _install.install.finalize_options(self)

    def run(self):
        # Carry out normal procedure
        _install.install.run(self)
        raise NotImplementedError("Install command is not yet available - coming soon!")


# Inspect to find current path
modpath = inspect.getfile(inspect.currentframe())
distropath = abspath(join(dirname(modpath), '..'))
