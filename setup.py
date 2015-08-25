"""Setup Cheshire3 for Archives Hub.

Although Cheshire3 for Archives Hub is not a pure Python package,
needing to be unpacked and used in situ, the convention of using setup.py
as the installation method is followed.
"""

from __future__ import with_statement

from os.path import dirname
import inspect

# Import Setuptools
from ez_setup import use_setuptools
use_setuptools()

from setuptools import setup
from pip.req import parse_requirements

from archiveshub.setuptools.commands import (
    develop,
    install,
    upgrade,
    uninstall,
    unavailable_command
)

_name = 'archiveshub'
_version = '3.3.10'

# Inspect to find current path
setuppath = inspect.getfile(inspect.currentframe())
setupdir = dirname(setuppath)

# Requirements
_install_requires = [str(req.req)
                     for req
                     in parse_requirements('requirements.txt')
                     if req.req
                     ]


setup(
    name=_name,
    version=_version,
    description='Cheshire3 for Archives Hub',
    packages=[],
    requires=['cheshire3'],
    install_requires=_install_requires,
    extras_require={
        'docs': ["sphinx"],
        'nlp': ['cheshire3[nlp]'],
    },
    entry_points={
        'console_scripts': [
            'ah-serve = archiveshub.deploy.cherrypy_serve:main'
        ],
    },
    test_suite="archiveshub.test.testAll",
    author='John Harrison',
    author_email=u'john.harrison@liv.ac.uk',
    maintainer='John Harrison',
    maintainer_email=u'john.harrison@liv.ac.uk',
    license="BSD",
    classifiers=[
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
    cmdclass={
        'bdist_egg': unavailable_command,
        'bdist_rpm': unavailable_command,
        'bdist_wininst': unavailable_command,
        'develop': develop,
        'install': install,
        'upgrade': upgrade,
        'uninstall': uninstall
    },
)
