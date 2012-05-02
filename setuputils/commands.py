"""Setuptools command sub-classes."""

import os
import inspect

from os.path import abspath, dirname, join, exists
from pkg_resources import normalize_path

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
        self.with_httpd = normalize_path(self.with_httpd)

    def install_for_development(self):
        global distropath
        # Carry out normal procedure
        _develop.develop.install_for_development(self)
        # Install Apache HTTPD configuration stub file
        am = ApacheModifier(self.with_httpd)
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
        
    def uninstall_link(self):
        # Carry out normal procedure
        _develop.develop.uninstall_link(self)
        # Install Apache HTTPD configuration stub file
        am = ApacheModifier(self.with_httpd)
        am.uninstall_apache_config()
        # Remove web directory for static search pages
        am.uninstall_web_dir()
        # Remove symbolic links
        from cheshire3.internal import cheshire3Home
        # Link to Cheshire3 database config stub
        os.remove(join(cheshire3Home, 
                       'cheshire3', 
                       'dbs', 
                       'configs.d', 
                       'db_ead.xml')
                   )
        # Link to database directory
        os.remove(join(cheshire3Home, 
                       'cheshire3', 
                       'dbs', 
                       'ead')
                   )
        # Link to web app directory
        os.remove(join(cheshire3Home, 
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
