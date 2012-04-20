"""Setup Cheshire3 for Archives.

Although Cheshire3 for Archives is not a pure Python package, the convention 
of using setup.py as the setup file are followed.

"""

import os

from os.path import abspath, dirname, join, exists, expanduser
from setuptools import setup

from setuputils.commands import develop, install, unavailable_command 


_name = 'cheshire3-ead'
_version = '3.6.0'


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
        if exists(join(apache_base_path, 'www')):
            self.apache_htdocs_path = join(apache_base_path, 'www')
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
        """Create an Apache HTTPD configuration stub file.
        
        This tells the web server how to run the  web apps.
        """
        # Read in Apache configuration stub template
        self._unpackcp(join(distropath, 'install', 'conf.d', 'ead.conf'), 
                       join(self.apache_base_path, 'conf.d', 'ead.conf')
                       )
        
    def create_web_dir(self):
        """Create a web directory."""
        os.mkdir(join(self.apache_htdocs_path, 'ead'))

    def install_web_landing_page(self):
        self._unpackcp(join(distropath, 'install', 'htdocs', 'ead', 'index.html'),
                       join(self.apache_htdocs_path, 'ead', 'index.html')
                       )
    

# Inspect to find current path
setuppath = inspect.getfile(inspect.currentframe())
distropath = abspath(dirname(setuppath))


setup(
    name = _name,
    version = _version,
    description = 'Cheshire3 for Archives',
    packages=[],
    requires=['cheshire3'],
    install_requires=['cheshire3 >= 1.0.0b37'],
    author = 'John Harrison, et al.',
    author_email = u'john.harrison@liv.ac.uk',
    maintainer = 'John Harrison',
    maintainer_email = u'john.harrison@liv.ac.uk',
    license = "BSD",
    classifiers = [
        "Intended Audience :: Developers",
        "Intended Audience :: Information Technology",
        "License :: OSI Approved :: BSD License",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Topic :: Internet :: WWW/HTTP :: Indexing/Search",
        "Topic :: Internet :: Z39.50",
        "Topic :: Text Processing :: Indexing",
        "Topic :: Text Processing :: Linguistic",
        "Topic :: Text Processing :: Markup"
    ],
    cmdclass = {
                'bdist_egg': unavailable_command,
                'bdist_rpm': unavailable_command,
                'bdist_wininst': unavailable_command,
                'develop': develop,
                'install': install
                },
)
