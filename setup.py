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
