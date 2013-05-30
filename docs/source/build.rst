
Building the Archives Hub Database
==================================

Managing the Archives Hub EAD database is carried out using Python scripts
located in the EAD database directory, ``<archiveshub-base-directory>/dbs/ead``

Building the database involves 3 activities:

1. `Managing Contributors`_

2. `Loading Data`_

3. `Indexing Loaded Data`_


Managing Contributors
---------------------

The Archives Hub EAD Database maintains an internal registry of contributors
and where the data files for each contributor can be found. The reason for this
is to assist in managing permissions in the proposed contributor console. 

Contributors are managed using the ``contributors.py`` script. You can get help
on using this script at any time by running::

    $ python contributors.py --help

There are 3 commands:

add
    `Add a contributor`_

rm
    `Remove a contributor`_

list
    `List Registered contributors`_    


You can also get help for any of these commands using the ``--help`` option.
e.g. ::

    $ python contributors add --help


Add a Contributor
~~~~~~~~~~~~~~~~~

Adding a contributor requires at least one argument - the directory in which
the data for that contributor is located. You can supply an absolute path, a
relative path, or use the tilde=home directory notation. e.g.::

    $ python contributors.py add /home/user/data/aberdeen
    
    $ python contributors.py add ../../../mercurial/hubdata/aberdeen
    
    $ python contributors.py add ~/mercurial/hubdata/aberdeen


If you're adding a completely new contributor, and the directory for that
contributor does not exist yet, you can instruct the script to create it using
the ``-c`` or ``--create`` option. e.g.::

    $ python contributors.py add -c ~/mercurial/hubdata/newcontributor


By default, the name of the lowest level directory will be used as the internal
identifier for that contributor. If the name of the directory is unintuitive,
or cumbersome, you can over-ride this with the ``-i``, ``--id`` or
``--identifier`` option. e.g.::

    $ python contributors.py add --id name ~/mercurial/hubdata/1

    $ python contributors.py add --id shortname ~/mercurial/hubdata/verylongcontributorname


If you're happy to accept default behaviour, you can add many contributors at
once, e.g. by using a wildcard or glob pattern::

    $ python contributors.py add ~/mercurial/hubdata/*


Remove a Contributor
~~~~~~~~~~~~~~~~~~~~

Removing a contributor requires at least one argument - the name of the
contributor to remove. e.g.::

    $ python contributors.py rm aberdeen


It's possible for the script to determine the internal identifier from a
directory (assuming that you didn't add the contributor using an ``-i``,
``--id`` or ``--identifier`` option.) e.g.::

    $ python contributors.py rm ~/mercurial/hubdata/aberdeen


It's also possible to remove multiple contributors at once, e.g. by using a
wildcard or glob pattern::

    $ python contributors.py rm ~/mercurial/hubdata/*


List Registered Contributors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Listing the registered contributors will print out a list of the internal
identifiers, and the location of the data files for each registered
contributor. The command is simply::

    $ python contributors.py list



Loading Data
------------

The process of loading data into the database is separated from the process of
`indexing loaded data`_. This enables updated descriptions from one or more
contributor(s) to be loaded into the Archives Hub at any time and without
the need to re-index the entire database [#partidx]_. Re-indexing the database
is computationally expensive and takes a non-trivial amount of time and should
therefore be performed less frequently.

.. [#partidx] partial indexing is less efficient and can result in unexpected
   results if not handled correctly. It has therefore not recommended for the
   Archives Hub service.

Data is loaded using the ``load.py`` script. You can get help
on using this script at any time by running::

    $ python load.py --help


It's possible to load data from one or more contributors by specifying the
internal identifier(s)::

    $ python load.py aberdeen


As when managing contributors, it's possible for the script to determine the
internal identifier from a directory path (assuming that you didn't add the
contributor using an ``-i``, ``--id`` or ``--identifier`` option.) e.g.::

    $ python load.py ~/mercurial/hubdata/aberdeen


It's also possible to load data from multiple contributors at once, e.g. by
using a wildcard or glob pattern::

    $ python load.py ~/mercurial/hubdata/a*


To load data from all registered contributors, simply run the script without
any named contributors::

    $ python load.py


Special Cases (without components/components only)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, ``load.py`` will load descriptions and their components. If you
want to over-ride this behaviour you can use the options:

``-m``, ``--main``, ``--no-components``
    load only collection-level descriptions

``-x``, ``--no-descriptions``, ``--components-only``
    load only components


Indexing Loaded Data
--------------------

Main Database
~~~~~~~~~~~~~

Indexing the Archives Hub has been designed to be a non-disruptive process,
meaning that it can safely be carried out without disrupting the live service
without the need for elaborate work-arounds (entire offline databases etc.)

This is achieved by creating new indexes in an "offline" area and replacing the
live indexes with the offline ones once indexing is complete. There are also
some rudimentary checks in place to ensure that the live indexes are not
replaced with broken or incomplete new ones.

Data is indexed using the ``index.py`` script. You can get help
on using this script at any time by running::

    $ python index.py --help
 

To (re)index the database::

    $ python index.py


Controlling Indexing Behavior
'''''''''''''''''''''''''''''

Indexing behavior can be controlled by supplying options to the script:

``-l``, ``--live``
    Load directly into the live indexes. This option is not recommended for
    production use, but may be useful in a development, testing or disaster
    recovery context when maintaining the existing live indexes is not
    important.
    ::
    
        $ python index.py --live

    
``-o``, ``--offline``
    Load into the offline indexes but do not replace the live indexes. This
    option allows for human intervention between indexing and making the new
    indexes live.
    ::

        $ python index.py --offline


``-b``, ``--background``
    Load into offline indexes and replace live indexes when complete (assuming
    that tests are passed.) This is currently the default behavior.
    ::
    
        $ python index.py --background


``-n``, ``--no-test``
    Skip testing of new offline indexes when indexing in background mode.
    By default, tests must pass before before new indexes replace live ones.
    This option may be useful in non-production context where tests are
    expected to fail, e.g. when only a sub-set of the data has been loaded.
    
        $ python index.py --background --no-test


Subject Finder
~~~~~~~~~~~~~~

To (re)index the database including the subject finder add the ``-j`` or
``--subjects`` option.
::

    $ python index.py --subjects


This can be used in conjunction with any of the main indexing behavior options,
however please note that the Subject Finder is always built in "live" mode.
::

    $ python index.py --background --subjects
 