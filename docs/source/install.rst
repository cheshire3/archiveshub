:tocdepth: 2

Install the Archives Hub
========================

Dependencies
------------

``archiveshub`` should be compatible with any Unix-like O/S. At the  present
time it has not been tested on any Microsoft Windows O/S.


XML Libraries
~~~~~~~~~~~~~

``archiveshub`` requires some XML processing libraries, for Debian flavour
Linux::

    sudo apt-get install libxml2-dev
    sudo apt-get install libxslt-dev

or for RedHat flavour Linux::

    sudo yum install libxml2-devel
    sudo yum install libxslt-devel


Python
~~~~~~

``archiveshub`` is a 'Python`_ package and requires `Python`_ 2.6.0 or later.
It has not yet been verified as `Python`_ 3 compliant. You will need to have
`Python`_ available on your system, including the "development headers".
::

    sudo apt-get install python-dev

or::

    sudo yum install python-devel


We also highly recommend that you use `virtualenv`_ to isolate your protect
against dependency conflicts that may occur with other `Python`_
applications on your system (many Linux distributions use `Python`_ for
user-interface tasks, including package management.)::

    sudo apt-get install python-virtualenv

or::

    sudo yum install python-virtualenv


If you decide against using ``virtualenv`` then you will need to ensure that
`pip`_ is available.::

    sudo apt-get install python-pip

or::

    sudo yum install python-pip


uWSGI
~~~~~

`uWSGI <https://uwsgi-docs.readthedocs.org/en/latest/index.html>`_ is stack for
deploying network applications. It is used to run ``archiveshub``'s `Python`_
based :abbr:`WSGI (Web Server Gateway Interface)` applications.::

    sudo pip install "uwsgi >= 2.0"

Check that the available version is the newly installed and up-to-date one::

    uwsgi --version
    2.0.x


Apache Web-Server with uWSGI support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    sudo apt-get install apache2 apache2-dev
    sudo a2enmod proxy_http

or::

    sudo yum install httpd


Then install mod-proxy-uwsgi by hand... (alternatively is to proxy over HTTP
but it's slower)::

    curl -o uwsgi-2.0.3.tar.gz http://projects.unbit.it/downloads/uwsgi-2.0.3.tar.gz
    tar xzf uwsgi-2.0.3.tar.gz
    cd uwsgi-2.0/apache
    sudo apxs2 -i -c mod_proxy_uwsgi.c


PostgreSQL
~~~~~~~~~~

``archiveshub`` makes use of PostgreSQL for some aspects of data persistence
(storing Queries and ResultSets from users in real time). This requires that
your system have PostgreSQL installed, with the development header files and
libraries.::

    sudo apt-get install postgresql-9.1
    sudo apt-get install postgresql-client-9.1
    sudo apt-get install libpq-dev

or::

    sudo yum install postgresql-server
    sudo yum install postgresql-devel


Mercurial
~~~~~~~~~

Mercurial is required to retrieve and maintain up-to-date copies of the
Archives Hub EAD data and web-content.::

    sudo apt-get install mercurial


Cheshire3
~~~~~~~~~

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

    mkdir ~/ve/ah<version>
    virtualenv ~/ve/ah<version>
    ...
    source ~/ve/ah<version>/bin/activate


Obtain A Distribution
~~~~~~~~~~~~~~~~~~~~~

1. Download a distribution from an appropriate location, such as one of those
   below, or one supplied to you by the developer

   Specific Version
       https://github.com/cheshire3/archiveshub/archive/3.2.0.tar.gz

   Latest Release Version
       https://github.com/cheshire3/archiveshub/archive/master.tar.gz

2. Rename the downloaded file to something sensible, e.g.::

      mv 3.2.0.tar.gz archiveshub-3.2.0.tar.gz

   or::

      mv master.tar.gz archiveshub.tar.gz


Unpack the Distribution
~~~~~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    cd ~/cheshire3

2. Unzip the distribution::

       gunzip archiveshub-3.2.0.tar.gz

3. Untar the distribution::

       tar xf archiveshub-3.2.0.tar.gz


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       cd archiveshub

2. Install dependencies::

       pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       python setup.py install


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Configure Apache HTTP To Server the Applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Allow Apache to create network connections (SELinux setups only)::

    setsebool httpd_can_network_connect true


2. Add and enable a virtualhost for the Archives Hub to the root Apache
   installation.::

       sudo cp www/uwsgi/apache/proxy_uwsgi.load /etc/apache2/mods-available/proxy_uwsgi.load
       sudo a2enmod proxy_uwsgi
       sudo cp www/uwsgi/apache/archiveshub.conf /etc/apache2/sites-available/ah3.2
       sudo a2ensite ah3.2
       sudo apache2 restart


Start the uWSGI "Emperor"
~~~~~~~~~~~~~~~~~~~~~~~~~

Start the `uWSGI Emperor <https://uwsgi-docs.readthedocs.org/en/latest/Emperor.html>`_
- this will be responsible for managing ``archiveshub``'s `Python`_ based
:abbr:`WSGI (Web Server Gateway Interface)` applications.

First test that the uWSGI can be started manually::

    sudo uwsgi --ini /home/cheshire/archiveshub/www/uwsgi/emperor.ini --emperor-tyrant

Check that the applications are running, i.e. check the following URLs for a
reasonable response:

* http://host/api/sru/ead?operation=searchRetrieve&version=1.2&query=police
* http://host/api/OAI-PMH/2.0/ead?verb=Identify
* http://host/search/search.html?query=police
* http://host/data/gb2110-lsbu

If successful, close the manually started uwsgi process with Ctrl-C, then
configure Upstart to manage the process through reboots etc.::

    sudo cp /home/cheshire/archiveshub/www/uwsgi/upstart/archiveshub.conf /etc/init/archiveshub.conf
    initctl start archiveshub


Starting the uWSGI "Emperor" Manually
'''''''''''''''''''''''''''''''''''''

If you have successfully installed the Upstart configuration, the following
is not necessary, but can be used for testing/debugging.::

    sudo mkdir -p /var/log/uwsgi/app
    sudo uwsgi --ini /home/cheshire/archiveshub/www/uwsgi/emperor.ini --emperor-tyrant --logto /var/log/uwsgi/app/ah.log

.. NOTE::
   This can be daemonised instead::

       sudo uwsgi --ini /home/cheshire/archiveshub/www/uwsgi/emperor.ini --emperor-tyrant --daemonize /var/log/uwsgi/app/ah.log

.. WARNING::
   Do not daemonize the process if managing through something like Upstart, as
   this will cause the managing process to lose the uWSGI process.


Test Deployment
---------------

This section describes installation into an environment intended to provide a
testing platform, for example a beta server.


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    mkdir ~/ve/ah<version>
    virtualenv ~/ve/ah<version>
    ...
    source ~/ve/ah<version>/bin/activate


Obtain A Distribution
~~~~~~~~~~~~~~~~~~~~~

1. Download a distribution from an appropriate location, such as one of those
below, or one supplied to you by the developer

   Specific Version
       https://github.com/cheshire3/archiveshub/archive/3.2.0.tar.gz

   Bleeding Edge Development Version
       https://github.com/cheshire3/archiveshub/archive/develop.tar.gz

2. Rename the downloaded file to something sensible, e.g.::

    mv 3.2.0.tar.gz archiveshub-3.2.0.tar.gz

    mv develop.tar.gz archiveshub-develop-`date +%Y-%m-%d`.tar.gz


Unpack the Distribution
~~~~~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    cd ~/cheshire3

2. Unzip the distribution::

       gunzip archiveshub-3.2.0.tar.gz

3. Untar the distribution::

       tar xf archiveshub-3.2.0.tar.gz


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       cd archiveshub

2. Install dependencies::

       pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       python setup.py install


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Start The Test Server
~~~~~~~~~~~~~~~~~~~~~

::

    ah-serve


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

We also highly recommend that you use virtualenv to isolate your project
against dependency conflicts that may occur with other `Python`_ applications
on your system (many Linux distributions use `Python`_ for user-interface
tasks, including package management.)


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    mkdir ~/ve/ah
    virtualenv ~/ve/ah
    ...
    source ~/ve/ah/bin/activate


Get The Source Code
~~~~~~~~~~~~~~~~~~~

1. Move to an appropriate place on your filesystem::

    cd ~/cheshire3

2. Clone the GitHub repository.::

       git clone http://github.com/cheshire3/archiveshub

   **Note**: If you intend to contribute back to the project, we recommend
   creating your own fork and cloning from your fork instead [githubfork]_,
   e.g.::

       git clone http://github.com/<your-github-username>/archiveshub


.. [githubfork] https://help.github.com/articles/fork-a-repo


Install ``archiveshub``
~~~~~~~~~~~~~~~~~~~~~~~

1. Move into the repository::

       cd archiveshub

2. Install dependencies::

       pip -r requirements.txt

3. Install ``archiveshub`` in `develop` mode::

       python setup.py develop


Build the Archives Hub Database(s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See :doc:`build`


Start The Test Server
~~~~~~~~~~~~~~~~~~~~~

::

    ah-serve


.. Links
.. _Python: http://www.python.org/
.. _virtualenv: http://www.virtualenv.org/en/latest/
.. _pip: http://www.pip-installer.org/en/latest/
.. _`cheshire3`: https://pypi.python.org/pypi/cheshire3
.. _`Cheshire3 Information Framework`: http://cheshire3.org
.. _`git-flow`: https://github.com/nvie/gitflow
.. _Apache: http://httpd.apache.org
