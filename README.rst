Cheshire3 for Archives
======================

3rd September 2012 (2012-09-03)


Contents
--------

 - `Description`_
 - `Authors`_
 - `Latest Version`_
 - `Installation`_
 - `Requirements / Dependencies`_
 - `Documentation`_
 - `Roadmap`_
 - `Bugs, Feature requests etc.`_
 - `Licensing`_
 - `Use`_
    - `Loading Data`_
        - `Batch Loading`_
        - `Using the Admin Console`_
    - `Searching`_
        - `Using the Web App`_
        - `Using the SRU API`_
            - `Available Indexes`_
            - `Available Record Schemas`_
            - `Disabling SRU`_
        - `Harvesting Using OAI-PMH`_
            - `Available Record Schemas (Metadata Prefixes)`_
            - `Available Sets`_
            - `Disabling OAI-PMH`_


Description
-----------

Cheshire3 for Archives is a complete system for searching and delivering EAD 
documents via the web. It features:

* Full document and component indexing to item level
* Customisable search and display web-interface
* Faceted result browsing
* Subject clustering / Entry Level Vocabulary
* SRU, OAI-PMH and Z39.50 APIs
* Online administration interface
    * add, delete records
    * rebuild, reindex database
    * manage users allowed to perform administrative tasks
* Online Cataloguing
    * Create new files
    * Import existing EAD files for editing
    * Export created/edited records for immediate inclusion in the database
   

Authors
-------

Cheshire3 Team at the `University of Liverpool`_:

* **John Harrison** john.harrison@liv.ac.uk
* Catherine Smith

(Current maintainer in **bold**)


Latest Version
--------------

The latest stable version will be available from our website:

http://download.cheshire3.org/download/ead/

Source code is under version control and available from:

http://github.com/cheshire3/cheshire3-ead

Development in the GitHub repository will follow (at least to begin with) 
Vincent Driessen's branching model, and use git-flow to facilitate this. For 
details of the model, see:

http://nvie.com/posts/a-successful-git-branching-model/


Installation
------------

When installing a stable release from our website, please follow the procedure 
outlined on the download page:
http://cheshire3.org/download/ead/index.html#docs

When installing from a clone of the git repository:

1. Run ```python setup.py develop```
2. Change directory to (Cheshire3-base-directory)/cheshire3/www/ead
3. Open localConfig.py in a text editor.
4. Modify preference switches as desired.
5. Insert appropriate values for:
    * `repository_name`
    * `repository_link`
    * `repository_logo` 
    * `localhost`
    * `outgoing_email_username`
    * `outgoing_email_host`
6. Save and close.
7. Generate customized search pages with the command: 
    `python buildCustomPages.py`
8. Restart Apache. This is necessary to load some special configurations for 
    the search interface

OK, you're done! You can now start using the system to index, search, browse, 
and display your EAD finding aids.


Requirements / Dependencies
---------------------------

Cheshire3 for Archives requires a working installation of Cheshire3, with the 
optional web and sql feature packs - this requirement should be automatically 
resolved during installation.

Cheshire3 requires Python 2.6.0 or later. It has not yet been verified as 
Python 3 compliant.

Cheshire3 for Archives should be compatible with any Unix-like O/S. At the 
present time it has not been tested on any Microsoft Windows O/S.


Documentation
-------------

You can find out more about the application, including capabilities, APIs and 
features added in this release on the about page:

http://(your-host)/ead/about.html

Documentation on using the search and display web app can be found at:

http://(your-host)/ead/help.html

Documentation on using the Admin Console can be found at:

http://(your-host)/ead/admin/help.html

All scripts intended for use by administrative users should return help when 
passed the `--help` option.

Further documentation for developers can be found in the docs/ folder of the  
distribution. Before starting work on any of the sub-systems (search, display,
admin, editor etc.) developers should read any relevant documentation in the 
docs/ directory.


Roadmap
-------

**Version 3.6 – September 2012**

* Improved Unique Identifier derivation
* Consolidate recent `Archives Hub`_ display enhancements (Record Resolver,
  Utility Bar)
* Consolidate recent `EAD Editor`_ enhancements (Support for improved Unique
  Identifiers, Multiple field addition and editing)


**Version 3.7 – January 2013**

* Migrate existing `mod_python`_ handlers to WSGI_ Applications
* Search within descriptions
* Convert user editable configurations to a more user friendly format
  (probably YAML_)


**Version 3.8 – July 2013**

* Support for `EAD Schema`_
* Support for `EAC-CPF`_


Bugs, Feature requests etc.
---------------------------

Bug reports, feature requests etc. should be made using the GitHub issue 
tracker:
https://github.com/cheshire3/cheshire3-ead/issues


Licensing
---------

Copyright &copy; 2005-2012, the `University of Liverpool`_.
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, 
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.
 * Neither the name of the `University of Liverpool`_ nor the names of its 
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

1. Change directory to (Cheshire3-base-directory)/cheshire3/dbs/ead
2. Copy EAD data files into the data directory.
3. Build the database and indexes with the command: ::
 
    python run.py -load -load_components -cluster


Using the Admin Console
'''''''''''''''''''''''

1. Create an administration account

   1. Change directory to (Cheshire3-base-directory)/cheshire3/dbs/ead
   
   2. Run the command: ::
   
       python run.py -adduser
       
   3. Follow the prompts for provide the required info
    
2. See the admin console help page at:

   http://(your-host)/ead/admin/help.html#files_upload


Searching
~~~~~~~~~

Using the Web App
'''''''''''''''''

Navigate to the following address in the web-browser:

http://(your-host)/ead/

A help page is available at:

http://(your-host)/ead/help.html#search


Using the SRU API
'''''''''''''''''

A complete guide to using the SRU interface is beyond the scope of this 
document. For details about the SRU protocol see:

http://www.loc.gov/standards/sru/

The base URI for the SRU interface will be:

http://(your-host)/services/ead


Available Indexes
`````````````````

*   rec.identifier

    Internal identifiers for each record. The values in this index are those 
    used to generate persistent unique URLs for each of the descriptions.

*   cql.anywhere

    All keywords from all records, regardless of their position within records. 
    Using the = relation means search for a phrase in this index.

*   dc.description

    Keywords from specific areas of records that give a good representation of 
    what the records is about. This includes titles, subjects and description 
    of the scope and content of the collect/item in question. Using the = 
    relation means search for a phrase in this index.

*   dc.title

    Precise titles and keywords from titles. Using the exact relation will 
    search for the full and precise title (wildcard are permitted), whereas 
    the other relations will search for keywords, = meaning search for a 
    phrase.

*   dc.identifier

    Unit identifier, or reference number assigned to a collection or item by 
    the cataloguer. Using the any or all relations will match partial 
    identifiers, assuming that they are separated by a non alpha-numerical 
    character.

*   dc.creator

    The name of the creator of the collection or item, as recorded by the 
    cataloguer.

*   dc.subject

    Subjects or topics, as assigned by the cataloguer.

*   bath.name

    Names of things, people, organizations or places.

*   bath.personalName

    Names of people.

*   bath.familyName

    Names of families (surnames)

*   bath.corporateName

    Names of any organizations, corporations or groups.

*   bath.geographicName

    Names of places, towns, regions, countries etc.

*   bath.genreForm

    Types of media represented in the collection or item, e.g. photographs, 
    audio recordings etc.

*   dc.date

    Significant dates, most commonly the date of creation of the material.

*   rec.creationDate

    The date and time at which the record was inserted into the database. 
    Please note that this is not the same as the date the EAD description was 
    created, nor is it guaranteed to remain unaltered; occasionally it may be 
    necessary to completely recreate the indexes, which will result in the 
    record creation time being updated.

*   rec.lastModifiedDate

    The date and time at which the index entries for the description were last 
    updated. Please note that this is not necessarily the same as the date the 
    content of the record was modified, nor does it guaranteed that the record 
    was actually altered at this time; occasionally it may be necessary to 
    reindex, which will result in the last modification time being updated, 
    as it is not practical to test every record for the presence of actual 
    modifications.

*   ead.istoplevel

    Values in this index are all 1. This index is used as a filter to 
    discriminate collections from the items contained within them.
    
    
Available Record Schemas
````````````````````````

*   ead

    info:srw/schema/1/ead-2002

    EAD 2002 – DTD Version

*   dc, srw_dc

    info:srw/schema/1/dc-v1.1

    Simple Dublin Core Elements (inside an srw_dc wrapper)

*   oai_dc

    http://www.openarchives.org/OAI/2.0/oai_dc/

    Simple Dublin Core Elements (inside an oai_dc wrapper)
    
    
    
Disabling SRU
`````````````

It is possible to disable the SRU Interface:

1. Change directory to (Cheshire3-base-directory)/cheshire3/dbs/ead

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

http://(your-host)/OAI/2.0/ead


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

1. Change directory to (Cheshire3-base-directory)/cheshire3/dbs/ead

2. Open the file config.xml

3. Change the line that reads:

    `<setting type="oai-pmh">1</setting>`

    to

    `<setting type="oai-pmh">0</setting>`


.. Links
.. _Python: http://www.python.org/
.. _Apache: http://httpd.apache.org 
.. _`University of Liverpool`: http://www.liv.ac.uk
.. _`Cheshire3 Information Framework`: http://cheshire3.org
.. _`Archives Hub`: http://archiveshub.ac.uk
.. _`EAD Editor`: http://archiveshub.ac.uk/eadeditor/
.. _WSGI: http://wsgi.org
.. _`EAD Schema`: http://www.loc.gov/ead/eadschema.html
.. _`EAC-CPF`: http://eac.staatsbibliothek-berlin.de/
.. _YAML: http://www.yaml.org/
.. _`mod_python`: http://modpython.org
