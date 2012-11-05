"""Utilities for installing configs, web-pages etc. into Apache HTTPD."""

import os
import inspect

from os.path import abspath, dirname, join, exists


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
    
    def __init__(self, apache_base_path):
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
        
    def _unpackcp(self, source, destination):
        # Read in src
        with open(source, 'r') as fh:
            tmpl = fh.read()
        # Make common modifications
        tmpl = tmpl.replace('%%%C3HOME%%%', self.cheshire3Home)
        # Write to dest
        with open(destination, 'w') as fh:
            fh.write(tmpl)
            
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
                                           'httpd.conf') 
            with open(default_httpd_conf_path, 'a') as fh:
                fh.write("Include conf.d/*.conf")
                
        self._unpackcp(join(distropath, 'install', 'conf.d', 'ead.conf'), 
                       join(confdir, 'ead.conf')
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
             os.remove(join(confdir, 'ead.conf'))
        
    def install_web_landing_page(self):
        destpath = join(self.apache_htdocs_path, 'ead')
        if not exists(destpath):
            os.mkdir(destpath)
        self._unpackcp(join(distropath, 
                            'install', 
                            'htdocs', 
                            'ead', 
                            'index.html'),
                       join(destpath, 'index.html'))
    
    def uninstall_web_dir(self):
        # Recursively remove the Cheshire3 for Archives directory from
        # Apache HTTPDs htdocs directory 
        web_dir = join(self.apache_htdocs_path, 'ead')
        for root, dirs, files in os.walk(web_dir, topdown=False):
            for name in files:
                os.remove(os.path.join(root, name))
            for name in dirs:
                os.rmdir(os.path.join(root, name))
        os.rmdir(web_dir)


# Inspect to find current path
modpath = inspect.getfile(inspect.currentframe())
moddir = dirname(modpath)
distropath = abspath(join(moddir, '..', '..'))
