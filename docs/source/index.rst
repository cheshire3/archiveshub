.. Archives Hub documentation master file, created by
   sphinx-quickstart on Wed May 29 11:51:44 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to archiveshub's documentation!
=======================================

Contents:

.. toctree::
   :maxdepth: 2

   install
   build
   license


About archiveshub
=================


The `Archives Hub`_ is an online gateway to the descriptions of archives held
in UK repositories (such as universities, company archives and local history
centres). It does not hold any archive material itself but provides a means to
cross-search archival descriptions from different institutions.

The `archiveshub`_ package is a specialized fork of `Cheshire3 for Archives`_
to support the multiple repository cross-search nature of the `Archives Hub`_.
If you're looking for software to provide searching and delivering EAD
documents via the web, then please have a look at `Cheshire3 for Archives`_
first.

Both `archiveshub`_ and `Cheshire3 for Archives`_ feature:

*  Full document and component indexing to item level
*  Customisable search and display web-interface provided by WSGI_ compliant
   applications, Mako_ templating and XSLT_
*  Faceted result browsing
*  Subject clustering / Entry Level Vocabulary
*  `SRU`_ and `OAI-PMH`_ APIs


Authors
-------

Cheshire3_ Team at the `University of Liverpool`_:

* John Harrison <john.harrison@liv.ac.uk>


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`


.. Links
.. _`Archives Hub`: http://archiveshub.ac.uk
.. _`archiveshub`: https://github.com/cheshire3/archiveshub
.. _`Cheshire3`: http://cheshire3.org
.. _`Cheshire3 for Archives`: https://github.com/cheshire3/cheshire3-archives
.. _`University of Liverpool`: http://www.liv.ac.uk
.. _`SRU`: http://www.loc.gov/standards/sru/
.. _`OAI-PMH`: http://www.openarchives.org/pmh/
.. _`WSGI`: http://wsgi.org
.. _`Mako`: http://www.makotemplates.org/
.. _`XSLT`: http://www.w3.org/TR/xslt
