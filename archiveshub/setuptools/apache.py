"""Utilities for installing configs, web-pages etc. into Apache HTTPD."""

import os
import inspect

from os.path import abspath, dirname, join, exists
from string import Template


class NoApacheException(EnvironmentError):
    """Exception raised when Apache HTTPD cannot be located."""

    def __init__(self, apache_base_path):
        self.reason = '''
Apache HTTPD is not installed in the expected location: {0}
You can specify the Apache HTTPD installation directory using the --with-httpd
option.'''.format(apache_base_path)

    def __str__(self):
        return str(self.__class__.__name__) + ": " + self.reason

    def __repr__(self):
        return str(self.__class__) + ": " + self.reason


class ApacheModifier(object):
    """A class to modify an Apache HTTPD installation."""

    def __init__(self, apache_base_path, develop=False):
        from cheshire3.internal import cheshire3Home
        self.cheshire3Home = cheshire3Home
        # Find directory for online content
        if exists(join(apache_base_path, 'htdocs')):
            self.apache_htdocs_path = join(apache_base_path, 'htdocs')
        elif exists(join(apache_base_path, 'www')):
            self.apache_htdocs_path = join(apache_base_path, 'www')
        elif exists(abspath(join(apache_base_path,
                                 '..', '..',
                                 'var', 'www', 'html'))):
            self.apache_htdocs_path = abspath(join(apache_base_path,
                                                   '..', '..',
                                                   'var', 'www', 'html'))
        else:
            raise NoApacheException(apache_base_path)
        self.apache_base_path = apache_base_path
        self.develop = develop

    def _unpackcp(self, source, destination):
        # Read in src
        with open(source, 'r') as fh:
            tmpl = Template(fh.read())
        # Make common modifications
        repl = {'C3ARCHIVESHOME': distropath}
        repl.update(os.environ)
        out = tmpl.safe_substitute(repl)
        # Write to dest
        with open(destination, 'w') as fh:
            fh.write(out)

    def install_apache_config(self):
        """Create and install an Apache HTTPD configuration stub file.

        This tells the web server how to run the  web apps.
        """
        # We already established that self.apache_base_path exists at __init__
        # just need to create conf.d if it doesn't exist
        confdir = join(self.apache_base_path, 'conf.d')
        # Read in Apache configuration stub template
        if not exists(confdir):
            os.mkdir(confdir)
            # If the dir wasn't there, we also need to tell the default httpd
            # config to include this directory
            default_httpd_conf_path = join(self.apache_base_path,
                                           'conf',
                                           'httpd.conf'
                                           )
            with open(default_httpd_conf_path, 'a') as fh:
                fh.write("Include conf.d/*.conf")
        if self.develop:
            # Create a soft link to the file
            os.symlink(
                join(distropath, 'www', 'uwsgi', 'apache', 'archiveshub.conf'),
                join(confdir, 'archiveshub.conf')
            )
        else:
            # Copy the file with mods
            self._unpackcp(
                join(distropath, 'www', 'uwsgi', 'apache', 'archiveshub.conf'),
                join(confdir, 'archiveshub.conf')
            )

    def uninstall_apache_config(self):
        """Uninstall an Apache HTTPD configuration stub file.

        This stub file tells the web server how to run the  web apps, but we
        want it to stop doing that.
        """
        # We already established that self.apache_base_path exists at __init__
        confdir = join(self.apache_base_path, 'conf.d')
        # Remove Apache configuration stub template
        if exists(confdir):
            os.remove(join(confdir, 'archiveshub.conf'))


# Inspect to find current path
modpath = inspect.getfile(inspect.currentframe())
moddir = dirname(modpath)
distropath = abspath(join(moddir, '..', '..'))
