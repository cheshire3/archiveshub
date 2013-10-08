"""WSGI Application Configuration"""

from ConfigParser import SafeConfigParser
try:
    from CStringIO import CStringIO as StringIO
except ImportError:
    from StringIO import StringIO
from pkg_resources import Requirement, resource_filename


# Default configuration
configDefaults = StringIO("""
[icons]
base-url = /images
forward-url = %(base-url)s/search/forward.png
fast-forward-url = %(base-url)s/search/fforward.png
rewind-url = %(base-url)s/search/back.png
fast-rewind-url = %(base-url)s/search/fback.png
plus-url = %(base-url)s/structure/form_add_row.png
what-url = %(base-url)s/structure/form_tip.png
folder-open-url = %(base-url)s/search/folderOpen.png
folder-closed-url = %(base-url)s/search/folderClosed.png
no-hits-url = %(base-url)s/search/no_hits.png

[cache]
# This section contains configuration for where to cache HTML copies of
# descriptions
html_cache_path = {html_cache_path}
html_file_size_kb = 50

[casing]
# Configuration settings related to capitalization
# Comma separate lists of words that should always appear in lower case
always_lower = a,and,by,etc,for,in,is,of,on,or,s,th,that,the,to
# Comma separate lists of words that should always appear in UPPER CASE
always_upper = AA,BBC,BT,CNN,UK,US,USA
# Regular expression for Roman numerals
roman_numeral_regex = ^M{{0,4}}(CM|CD|D?C{{0,3}})(XC|XL|L?X{{0,3}})\
(IX|IV|V?I{{0,3}})$

[email]
username = archiveshub
host = mailrouter.example.com
port = 25

[facets]
dc.subject = Subject
dc.creator = Creator
vdb.name = Contributor

[sortby]
weight = Relevance
dc.title = Title
dc.creator = Creator
dc.date = Date
dc.identifier = Reference
""".format(
    html_cache_path=resource_filename(
        Requirement.parse('archiveshub'),
        'www/ead/html'
    )
))

# App Configuration
config = SafeConfigParser()
config.readfp(configDefaults, 'hard-coded')
