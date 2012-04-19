"""Setup Cheshire3 for Archives.

Although Cheshire3 for Archives is not a pure Python package, the convention 
of using setup.py as the setup file are followed.

"""

import os
import inspect

from os.path import abspath, dirname, join
from setuptools import setup
from setuptools.command import develop as _develop
from setuptools.command import install as _install


class develop(_develop.develop):
    def initialize_options(self):
        _develop.develop.initialize_options(self)

    def finalize_options(self):
        _develop.develop.finalize_options(self)

    def run(self):
        # Carry out normal procedure
        _develop.develop.run(self)
        # Create symbolic links
        from cheshire3.internal import cheshire3Home
        # Inspect to find current path
        setuppath = inspect.getfile(inspect.currentframe())
        setupdir = abspath(dirname(setuppath))
        # link to Cheshire3 database config stub
        os.symlink(join(setupdir,
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
        # link to database directory
        os.symlink(join(setupdir,
                        'cheshire3', 
                        'dbs', 
                        'ead'), 
                   join(cheshire3Home, 
                        'cheshire3', 
                        'dbs', 
                        'ead')
                   )
        # link to web app directory
        os.symlink(join(setupdir,
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

setup(
    name = 'cheshire3-ead',
    version = '3.6.0',
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
    cmdclass = {'develop': develop, 'install': install},
)
