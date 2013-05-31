:tocdepth: 2

Install the Archives Hub
========================

Dependencies
------------

``archiveshub`` should be compatible with any Unix-like O/S. At the  present
time it has not been tested on any Microsoft Windows O/S.

``archiveshub`` is a `Python`_ package and requires `Python`_ 2.6.0 or later.
It has not yet been verified as `Python`_ 3 compliant. You will need to have
`Python`_ available on your system, including the "development headers".
::

    $ sudo apt-get install python-dev

or

::

    $ sudo yum install python-devel


We also highly recommend that you use `virtualenv`_ to isolate your protect
against dependency conflicts that may occur with other `Python`_
applications on your system (many Linux distributions use `Python`_ for
user-interface tasks, including package management.)
::

    $ sudo apt-get install python-virtualenv

or

::

    $ sudo yum install python-virtualenv


If you decide against using ``virtualenv`` then you will need to ensure that
`pip`_ is available.
::

    $ sudo apt-get install python-pip

or

::

    $ sudo yum install python-pip


``archiveshub`` is implemented within `Cheshire3 Information Framework`_,
and makes use of the optional web and sql feature packs. The `cheshire3`_
package requirement should be automatically resolved during any of the
installation methods described below.


Production Deployment
---------------------

This section describes installation into an environment intended to provide a
live public service.


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    $ mkdir ~/ve/ah<version>
    $ virtualenv ~/ve/ah<version>
    ...
    $ source ~/ve/ah<version>/bin/activate


Obtain A Distribution
~~~~~~~~~~~~~~~~~~~~~

1. Download a distribution from an appropriate location, such as one of those
   below, or one supplied to you by the developer

   Specific Version
       https://github.com/cheshire3/archiveshub/archive/3.2.0.tar.gz

   Latest Release Version
       https://github.com/cheshire3/archiveshub/archive/master.tar.gz

2. Rename the downloaded file to something sensible, e.g.::

      $ mv 3.2.0.tar.gz archiveshub-3.2.0.tar.gz

   or::

      $ mv master.tar.gz archiveshub.tar.gz


Unpack the Distribution
~~~~~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    $ cd ~/cheshire3

2. Unzip the distribution::

       $ gunzip archiveshub-3.2.0.tar.gz

3. Untar the distribution::

       $ tar xf archiveshub-3.2.0.tar.gz


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       $ cd archiveshub

2. Install dependencies::

       $ pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       $ python setup.py install


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Configure Apache HTTP To Server the Applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TBC


Test Deployment
---------------

This section describes installation into an environment intended to provide a
testing platform, for example a beta server.


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    $ mkdir ~/ve/ah<version>
    $ virtualenv ~/ve/ah<version>
    ...
    $ source ~/ve/ah<version>/bin/activate


Obtain A Distribution
~~~~~~~~~~~~~~~~~~~~~

1. Download a distribution from an appropriate location, such as one of those
below, or one supplied to you by the developer

   Specific Version
       https://github.com/cheshire3/archiveshub/archive/3.2.0.tar.gz

   Bleeding Edge Development Version
       https://github.com/cheshire3/archiveshub/archive/develop.tar.gz

2. Rename the downloaded file to something sensible, e.g.::

    $ mv 3.2.0.tar.gz archiveshub-3.2.0.tar.gz

    $ mv develop.tar.gz archiveshub-develop-`date +%Y-%m-%d`.tar.gz


Unpack the Distribution
~~~~~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    $ cd ~/cheshire3

2. Unzip the distribution::

       $ gunzip archiveshub-3.2.0.tar.gz

3. Untar the distribution::

       $ tar xf archiveshub-3.2.0.tar.gz


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       $ cd archiveshub

2. Install dependencies::

       $ pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       $ python setup.py install


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Start The Test Server
~~~~~~~~~~~~~~~~~~~~~

::

    $ ah-serve


Development
-----------

Source code is under version control and available from:

http://github.com/cheshire3/archiveshub

Development in the GitHub repository will follow (at least to begin with)
Vincent Driessen's branching model, and use `git-flow`_ to facilitate this.
For details of the model, see:

http://nvie.com/posts/a-successful-git-branching-model/

Accordingly, the ``master`` branch is stable and contains the most recent
release of the software; development should take place in (or by creating a
new ``feature/...`` branch from) the ``develop`` branch.

We also highly recommend that you use virtualenv to isolate your protect
against dependency conflicts that may occur with other `Python`_ applications
on your system (many Linux distributions use `Python`_ for user-interface
tasks, including package management.)


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    $ mkdir ~/ve/ah
    $ virtualenv ~/ve/ah
    ...
    $ source ~/ve/ah/bin/activate


Get The Source Code
~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    $ cd ~/cheshire3

2. Clone the GitHub repository.::

       $ git clone http://github.com/cheshire3/archiveshub

   **Note**: If you intend to contribute back to the project, we recommend creating your
   own fork and cloning from your fork instead [githubfork]_, e.g.::

       $ git clone http://github.com/<your-github-username>/archiveshub


.. [githubfork] https://help.github.com/articles/fork-a-repo


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       $ cd archiveshub

2. Install dependencies::

       $ pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       $ python setup.py develop


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Start The Test Server
~~~~~~~~~~~~~~~~~~~~~

::

    $ ah-serve


.. Links
.. _Python: http://www.python.org/
.. _virtualenv: http://www.virtualenv.org/en/latest/
.. _pip: http://www.pip-installer.org/en/latest/
.. _`cheshire3`: https://pypi.python.org/pypi/cheshire3
.. _`Cheshire3 Information Framework`: http://cheshire3.org
.. _`git-flow`: https://github.com/nvie/gitflow
.. _Apache: http://httpd.apache.org
