Archives Hub
============

13th August 2014 (2014-08-13)

.. image:: https://travis-ci.org/cheshire3/archiveshub.png?branch=master,develop
   :target: https://travis-ci.org/cheshire3/archiveshub
   :alt: Build Status


Contents
--------

-  `Description`_
-  `Authors`_
-  `Latest Version`_
-  `Installation`_
-  `Requirements / Dependencies`_
-  `Documentation`_
-  `Roadmap`_
-  `Bugs, Feature requests etc.`_
-  `Licensing`_
-  `Use`_

   -  `Loading Data`_

      -  `Batch Loading`_
      -  `Using the Admin Console`_

   -  `Searching`_

      -  `Using the Web App`_
      -  `Using the SRU API`_

         -  `Available Indexes`_
         -  `Available Record Schemas`_
         -  `Disabling SRU`_

      -  `Harvesting Using OAI-PMH`_

         -  `Available Record Schemas (Metadata Prefixes)`_
         -  `Available Sets`_
         -  `Disabling OAI-PMH`_


Description
-----------

The `Archives Hub`_ is an online gateway to the descriptions of archives held
in UK repositories (such as universities, company archives and local history
centres). It does not hold any archive material itself but provides a means to
cross-search archival descriptions from different institutions.

This repository is a specialized fork of `Cheshire3 for Archives`_ to support
the multiple repository cross-search nature of the `Archives Hub`_. If you're
looking for software to provide searching and delivering EAD documents via the
web, then please have a look at `Cheshire3 for Archives`_ first.

Both the `Archives Hub`_ and `Cheshire3 for Archives`_ feature:

*  Full document and component indexing to item level
*  Customisable search and display web-interface provided by WSGI_ compliant
   applications, Mako_ templating and XSLT_
*  Faceted result browsing
*  Subject clustering / Entry Level Vocabulary
*  `SRU`_ and `OAI-PMH`_ APIs


Authors
-------

Cheshire3 Team at the `University of Liverpool`_:

* **John Harrison** john.harrison@liv.ac.uk
* Catherine Smith

(Current maintainer in **bold**)


Latest Version
--------------

Source code is under version control and available from:

http://github.com/cheshire3/archiveshub

Development in the GitHub repository will follow (at least to begin with)
Vincent Driessen's branching model, and use `git-flow`_ to facilitate this.
For details of the model, see:

http://nvie.com/posts/a-successful-git-branching-model/

Accordingly, the ``master`` branch is stable and contains the most recent
release of the software; development should take place in (or by creating a
new ``feature/...`` branch from) the ``develop`` branch.


Requirements / Dependencies
---------------------------

`archiveshub`_ requires a working installation of Cheshire3_, with the
optional ``web`` and ``sql`` feature packs - this requirement should be
automatically resolved during installation.

Cheshire3_ requires Python_ 2.6.0 or later. It has not yet been verified as
Python_ 3 compliant.

`archiveshub`_ should be compatible with any Unix-like O/S. At the  present
time it has not been tested on any Microsoft Windows O/S.


Installation
------------

This section contains guidelines for setting up a demo/development
installation. For production deployment it is recommended that you build and
read the Sphinx `Documentation`_.


Create And Activate A Virtual Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We highly recommend that you use virtualenv_ to isolate your project
against dependency conflicts that may occur with other `Python`_ applications
on your system (many Linux distributions use `Python`_ for user-interface
tasks, including package management.)

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
   `creating your own fork <https://help.github.com/articles/fork-a-repo>`_
   and cloning from your fork instead, e.g.::

       git clone http://github.com/<your-github-username>/archiveshub


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

See `Batch Loading`_

Start The Test Server
~~~~~~~~~~~~~~~~~~~~~

::

    ah-serve

Documentation
-------------

HTML documentation can be generate using the command::

    python setup.py build_sphinx


The generated HTML documentation can then be found in docs/build/html/.

All scripts intended for use by administrative users should return help when
passed the `--help` option.


Roadmap
-------

**Version 3.2 – June 2013**

* Centralized architecture, centred around the version-controlled data
* Persistent Unique Identifiers (and therefore URIs) based on ``<unitid>``
* WSGI_ Applications for Search and Display
* Search within descriptions
* Editable configurations in standard INI-like format


**Version 3.3 – June 2014**

* Administration Interface

**Version 3.4 - ???**

* Support for `EAD Schema`_ ?
* Support for `EAC-CPF`_ ?


Bugs, Feature requests etc.
---------------------------

TBC


Licensing
---------

Copyright &copy; 2005-2014, the `University of Liverpool`_.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- Neither the name of the `University of Liverpool`_ nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Use
---

Loading Data
~~~~~~~~~~~~

Batch Loading
'''''''''''''

It's probably worth building and reading the Sphinx `Documentation`_ for full
details on this subject, but in short:

1. Go to the EAD database directory::

       cd dbs/ead

2. Add one or more contributors::

       python contributors.py add /path/to/contributor/dir

3. Load EAD files from the contributor(s)::

       python load.py

4. Index all loaded records::

       python index.py live


All Python_ scripts in the ``dbs/ead`` directory for managing the database
will return help on their use if run with the ``-h`` or ``--help`` option.
e.g.::

    python contributors.py --help


Using the Admin Console
'''''''''''''''''''''''

TBC


Searching
~~~~~~~~~

Using the Web App
'''''''''''''''''

Navigate to the following address in the web-browser:

http://(your-host)/search/

A help page is available at:

http://(your-host)/search/help.html#search


Using the SRU API
'''''''''''''''''

A complete guide to using the SRU interface is beyond the scope of this
document. For details about the SRU protocol see:

http://www.loc.gov/standards/sru/

The base URI for the SRU interface will be:

http://(your-host)/api/sru/ead


Available Indexes
`````````````````

rec.identifier
  Internal identifiers for each record. The values in this index are those
  used to generate persistent unique URLs for each of the descriptions.

cql.anywhere
  All keywords from all records, regardless of their position within records.
  Using the = relation means search for a phrase in this index.

dc.description
  Keywords from specific areas of records that give a good representation of
  what the records is about. This includes titles, subjects and description
  of the scope and content of the collect/item in question. Using the =
  relation means search for a phrase in this index.

dc.title
  Precise titles and keywords from titles. Using the exact relation will
  search for the full and precise title (wildcard are permitted), whereas
  the other relations will search for keywords, = meaning search for a
  phrase.

dc.identifier
  Unit identifier, or reference number assigned to a collection or item by
  the cataloguer. Using the any or all relations will match partial
  identifiers, assuming that they are separated by a non alpha-numerical
  character.

dc.creator
  The name of the creator of the collection or item, as recorded by the
  cataloguer.

dc.subject
  Subjects or topics, as assigned by the cataloguer.

bath.name
  Names of things, people, organizations or places.

bath.personalName
  Names of people.

bath.familyName
  Names of families (surnames)

bath.corporateName
  Names of any organizations, corporations or groups.

bath.geographicName
  Names of places, towns, regions, countries etc.

bath.genreForm
  Types of media represented in the collection or item, e.g. photographs,
  audio recordings etc.

dc.date
  Significant dates, most commonly the date of creation of the material.

rec.creationDate
  The date and time at which the record was inserted into the database.
  Please note that this is not the same as the date the EAD description was
  created, nor is it guaranteed to remain unaltered; occasionally it may be
  necessary to completely recreate the indexes, which will result in the
  record creation time being updated.

rec.lastModifiedDate
  The date and time at which the index entries for the description were last
  updated. Please note that this is not necessarily the same as the date the
  content of the record was modified, nor does it guaranteed that the record
  was actually altered at this time; occasionally it may be necessary to
  reindex, which will result in the last modification time being updated,
  as it is not practical to test every record for the presence of actual
  modifications.

ead.istoplevel
  Values in this index are all 1. This index is used as a filter to
  discriminate collections from the items contained within them.


Available Record Schemas
````````````````````````

ead
  info:srw/schema/1/ead-2002
  EAD 2002 – DTD Version

ead-hub
  info:srw/schema/2/raw/ead-2002
  EAD 2002 - DTD Version 2002, raw internal data edition (e.g. including
  ``<emph>`` subfields in ``<controlaccess>`` entries and without
  inter-relational record links having been resolved.)

dc, srw_dc
  info:srw/schema/1/dc-v1.1
  Simple Dublin Core Elements (inside an srw_dc wrapper)

oai_dc
  http://www.openarchives.org/OAI/2.0/oai_dc/
  Simple Dublin Core Elements (inside an oai_dc wrapper)


Disabling SRU
`````````````

It is possible to disable the SRU Interface:

1. Change directory to (repository-directory)/dbs/ead

2. Open the file config.xml

3. Change the line that reads:

    `<setting type="srw">1</setting>`

    to

    `<setting type="srw">0</setting>`


Harvesting Using OAI-PMH
''''''''''''''''''''''''

A complete guide to using the OAI-PMH interface is beyond the scope of this
document. For details about the OAI-PMH protocol see:

http://www.openarchives.org/

The base URI for the SRU interface will be:

http://(your-host)/api/OAI-PMH/2.0/ead


Available Record Schemas (Metadata Prefixes)
````````````````````````````````````````````

*   oai_dc

    http://www.openarchives.org/OAI/2.0/oai_dc/

    Simple Dublin Core Elements (inside an oai_dc wrapper)

*   srw_dc

    info:srw/schema/1/dc-v1.1

    Simple Dublin Core Elements (inside an srw_dc wrapper)

*   ead

    info:srw/schema/1/ead-2002

    EAD 2002 – DTD Version


Available Sets
``````````````

There is no set hierarchy defined - this OAI-PMH interface does not support
selective harvesting by sets.


Disabling OAI-PMH
`````````````````

It is possible to disable the OAI-PMH Interface:

1. Change directory to (repository-directory)/dbs/ead

2. Open the file config.xml

3. Change the line that reads:

    `<setting type="oai-pmh">1</setting>`

    to

    `<setting type="oai-pmh">0</setting>`


.. Links
.. _Python: http://www.python.org/
.. _Apache: http://httpd.apache.org 
.. _`University of Liverpool`: http://www.liv.ac.uk
.. _`Cheshire3`: http://cheshire3.org
.. _`Cheshire3 Information Framework`: http://cheshire3.org
.. _`Cheshire3 for Archives`: https://github.com/cheshire3/cheshire3-archives
.. _`archiveshub`: https://github.com/cheshire3/archiveshub
.. _`Archives Hub`: http://archiveshub.ac.uk
.. _`EAD Editor`: http://archiveshub.ac.uk/eadeditor/
.. _WSGI: http://wsgi.org
.. _`EAD Schema`: http://www.loc.gov/ead/eadschema.html
.. _`EAC-CPF`: http://eac.staatsbibliothek-berlin.de/
.. _`git-flow`: https://github.com/nvie/gitflow
.. _`SRU`: http://www.loc.gov/standards/sru/
.. _`OAI-PMH`: http://www.openarchives.org/pmh/
.. _`Mako`: http://www.makotemplates.org/
.. _`XSLT`: http://www.w3.org/TR/xslt
.. _virtualenv: http://www.virtualenv.org/en/latest/
