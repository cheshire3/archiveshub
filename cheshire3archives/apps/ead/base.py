"""Abstract Base Class for EAD WSGI Applications."""

import os
import sys
import mimetypes
import re

from ConfigParser import SafeConfigParser
from hashlib import sha1
from pkg_resources import Requirement, get_distribution
from pkg_resources import resource_filename, resource_stream, resource_string
from webob import Request, Response

try:
    from CStringIO import CStringIO as StringIO
except ImportError:
    from StringIO import StringIO

# Mako
from mako.lookup import TemplateLookup
from mako import exceptions
from tempfile import gettempdir

from cheshire3.baseObjects import Session
import cheshire3.exceptions as c3errors
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.utils import flattenTexts
from cheshire3.web.www_utils import html_encode


class EADWsgiApplication(object):
    """Abstract Base Class for EAD search/retrieve applications.
    
    Sub-classes must define the special __call__ method to make their instances
    of this class callable. This method should always call start_response, and
    return an iterable of string objects (list or generator). 
    
    NOTE: any method that does not return an iterable suitable for returning to
    the server, should be indicated as internal using a leading underscore,
    e.g. _fetch_record
    
    """
    
    def __init__(self, session, database, config):
        # Constructor method
        self.session = session
        self.database = database
        self.config = config
        self.queryFactory = self.database.get_object(session,
                                                     'defaultQueryFactory')
        self.queryStore = self.database.get_object(session,
                                                   'eadQueryStore')
        self.resultSetStore = self.database.get_object(session,
                                                       'eadResultSetStore')
        template_dir = resource_filename(
            Requirement.parse('cheshire3archives'),
            'www/apps/ead/tmpl'
        )
        mod_dir = os.path.join(gettempdir(), 'mako_modules')
        
        self.templateLookup = TemplateLookup(directories=[template_dir],
                                             output_encoding='utf-8',
                                             input_encoding='utf-8',
                                             module_directory=mod_dir,
                                             strict_undefined=False)
        self.defaultContext = {
            'version': get_distribution("cheshire3archives").version,
            'config': config
        }
        self.defaultContext.update(dict(config.items('brand')))

    def _setUp(self, environ):
        # Prepare application to handle a new request
        # Wrap environ in a Request object
        req = self.request = Request(environ, charset='utf8')
        # Create a Response object with defaults for status, encoding etc. 
        # Methods should over-ride these defaults as necessary
        self.response = Response()
        script = req.script_name
        self.defaultContext['SCRIPT'] = script
        # Set the base URL of this family of apps
        base = script
        self.defaultContext['BASE'] = base
        self.config.set('icons', 'base-url', req.relative_url('img'))
        # Set the URL of the data resolver
        self.defaultContext['DATAURL'] = req.relative_url('data')

    def _log(self, lvl, msg):
        print >> self.request.environ['wsgi.errors'], msg

    def _static_content(self, path):
        # Serve static content, CSS, images JavaScript etc.
        try:
            content = resource_string(
                Requirement.parse('cheshire3archives'),
                'www/apps/ead/{0}'.format(path)             
            )
        except IOError:
            return []
        else:
            mType, encoding = mimetypes.guess_type(path)
            if mType is not None:
                self.response.content_type = mType
            if encoding is not None:
                self.response.content_encoding = encoding
            return [content]

    def _render_template(self, template_name, **kwargs):
        try:
            template = self.templateLookup.get_template(template_name)
            d = self.defaultContext.copy()
            d.update(kwargs)
            return template.render(**d)
        except:
            
            return exceptions.html_error_template().render()

    def _set_cookie(self, name, value, **kwargs):
        # Prepend app name
        fullname = "c3archives_{0}".format(name)
        self.response.set_cookie(fullname, str(value), **kwargs)

    def _get_cookie(self, name):
        # Prepend app name
        fullname = "c3archives_{0}".format(name)
        return self.request.cookies.get(fullname)

    def _fetch_record(self, session, recid):
        # Fetch a Record
        session = self.session
        db = self.database
        queryFactory = self.queryFactory
        qString = 'rec.identifier exact "{0}"'.format(recid)
        q = queryFactory.get_query(session, qString)
        rs = db.search(session, q)
        try:
            return rs[0].fetch_record(session)
        except IndexError:
            raise c3errors.FileDoesNotExistException(recid)

    def _store_query(self, session, query):
        # Store a query, return its identifier
        identifier = sha1(query.toCQL()).hexdigest()
        # The fist 7 characters should be OK; it's good enough for git...
        query.id = identifier[:7]
        return self.queryStore.store_query(session, query)

    def _fetch_query(self, session, identifier):
        # Fetch a Query
        return self.queryStore.fetch_query(session, identifier)

    def _store_resultSet(self, session, rs):
        # Store the ResultSet
        if rs.id:
            return self.resultSetStore.store_resultSet(session, rs)
        else:
            return self.resultSetStore.create_resultSet(session, rs)

    def _fetch_resultSet(self, session, rsid):
        # Fetch a ResultSet
        try:
            return self.resultSetStore.fetch_resultSet(session, rsid)
        except c3errors.ObjectDoesNotExistException:
            query = self._fetch_query(session, rsid)
            rs = self.database.search(session, query)
            rs.id = rsid
            return rs

    def _fetch_mostRecentResultSet(self):
        # Return most recent resultSet, and values for startRecord,
        # maximumRecord and sortBy
        rsid = self._get_cookie('resultSet_id')
        startRecord = int(self._get_cookie('resultSet_startRecord'))
        maximumRecords = int(self._get_cookie('resultSet_maximumRecords'))
        sortBy = self._get_cookie('resultSet_sortBy').split(',')
        rs = self._fetch_resultSet(self.session, rsid)
        return rs, startRecord, maximumRecords, sortBy

    def _transformRecord(self, rec, txr_id):
        # Transform Record with Transformer, return unicode object
        txr = self.database.get_object(self.session, txr_id) 
        doc = txr.process_record(self.session, rec)
        self._log(10, "Transformed with {0}".format(txr_id))
        doc_uc = doc.get_raw(session).decode('utf-8')
        # Fix horrible Unicode space
        doc_uc = doc_uc.replace(u"\xa0", u" ")
        return doc_uc

    def _textFromRecord(self, rec):
        # Return a text representation of the Record
        global namespaceUriHash
        doc_uc = self._transformRecord(rec, "textTxr")
        # Resolve link to parent if a component
        try:
            parentId = rec.process_xpath(session,
                                         '/c3:component/@c3:parent', 
                                         namespaceUriHash)[0]
        except IndexError:
            return doc_uc
        else:
            parentId = parentId.split('/')[-1]
            try:
                parentPath = rec.process_xpath(session, 
                                               '/c3component/@xpath')[0]
            except IndexError:
                parentPath = rec.process_xpath(session, 
                                               '/c3:component/@c3:xpath', 
                                               namespaceUriHash)[0]
            parentRec = self._fetch_record(session, parentId)
            titles = self._backwalkTitles(parentRec, parentPath)
            hierarchy = [(' ' * 4 * x) + t[1] for x,t in enumerate(titles[:-1])]
            parentTitle = '\n'.join(hierarchy)
            txt = [u'In: {0}'.format(parentTitle),
                   u'-' * 78,
                   u'',
                   doc_uc
                   ]
            return u'\n'.join(txt)

    def _scanIndex(self, form):
        session = self.session
        queryFactory = self.queryFactory
        db = self.database
        formcodec = form.getfirst('_charset_', 'utf-8')
        idx = form.getfirst('fieldidx1', None)
        rel = form.getfirst('fieldrel1', 'exact')
        scanTerm = form.getfirst('fieldcont1', '')
        startTerm = int(form.getfirst('startTerm',
                                      form.getfirst('firstrec', 1)))
        maximumTerms = int(form.getfirst('maximumTerms',
                                         form.getfirst('numreq', 25)))
        rp = int(form.getfirst('responsePosition', (maximumTerms + 1) / 2))
        
        qString = u'%s %s "%s"' % (idx, rel, scanTerm)
        try:
            scanClause = queryFactory.get_query(session,
                                                qString,
                                                format="cql"
                                                )
        except:
            try:
                scanClause = queryFactory.get_query(session,
                                                    form,
                                                    format="www"
                                                    )
            except:
                self._log(40, 'Unparsable browse clause: %s' % qString)
                return self._render_template('fail/invalidBrowse.html',
                                             clause=qString)
        self._log(10, 'Browsing for "%s"' % (qString))
        hitstart = False
        hitend = False
        if (scanTerm == ''):
            hitstart = True
            rp = 0
        scanTermNorm = scanTerm
        if (rp == 0):
            scanData = db.scan(session, scanClause, maximumTerms, direction=">")
            if (len(scanData) < maximumTerms):
                hitend = True
        elif (rp == 1):
            scanData = db.scan(session, scanClause, maximumTerms, direction=">=")
            if (len(scanData) < maximumTerms):
                hitend = True
        elif (rp == maximumTerms):
            scanData = db.scan(session, scanClause, maximumTerms, direction="<=")
            scanData.reverse()
            if (len(scanData) < maximumTerms):
                hitstart = True
        elif (rp == maximumTerms + 1):
            scanData = db.scan(session, scanClause, maximumTerms, direction="<")
            scanData.reverse()
            if (len(scanData) < maximumTerms):
                hitstart = True
        else:
            # We ask for 1 extra term and trim it off later to check if there
            # are more terms (for navigation purposes)
            # Need to go up...
            try:
                scanData = db.scan(session, scanClause, rp + 1, direction="<=")
            except:
                scanData = []
            if (len(scanData) < rp + 1):
                hitstart = True
            else:
                scanData.pop(-1)
            # ... then down
            try:
                scanData1 = db.scan(session,
                                    scanClause,
                                    (maximumTerms - rp + 1) + 1,
                                    direction=">=")
            except:
                scanData1 = []
            
            if (len(scanData1) < (maximumTerms - rp + 1) + 1):
                hitend = True
            else:
                scanData1.pop(-1)
            # Try to stick them together
            try:
                if scanData1[0][0] == scanData[0][0]:
                    scanTermNorm = scanData.pop(0)[0]
                else:
                    scanData.insert(0, None)
                    scanData.pop(-1)
                    scanData1.pop(-1)
            except:
                pass
            scanData.reverse()
            scanData.extend(scanData1)
            del scanData1
        return {scanTermNorm: (hitstart, scanData, hitend)}


# Methods that could usefully be imported by Templates

def listCollections(session):
    "Return a list of Collection Identifier, Collection Title tuples."""
    # Get Database object
    db = session.server.get_object(session, session.database)
    identifierIdx = db.get_object(session, 'idx-collectionid')
    titleIdx = db.get_object(session, 'idx-collectiontitle')
    for rs in identifierIdx:
        term = rs.queryTerm
        titles = titleIdx.facets(session, rs)
        yield (term, titles[0][0])
    

def collectionFromComponent(session, record):
    # Get Database object
    db = session.server.get_object(session, session.database)
    wf = db.get_object(session, "CollectionFromComponentWorkflow")
    return wf.process(session, record)


def backwalkComponentTitles(session, record):
    # Get Database object
    db = session.server.get_object(session, session.database)
    normIdFlow = db.get_object(session, 'normalizeDataIdentifierWorkflow')
    normIdFlow.load_cache(session, db)
    xpath = record.process_xpath(session, '/c3component/@xpath')[0]
    # Get parent Record
    parentRec = collectionFromComponent(session, record)
        
    def __processNode(node):
        t = node.xpath('string(./did/unittitle)')
        if not len(t):
            t = '(untitled)'
        i = node.xpath('string(./did/unitid)')
        if len(i):
            i = parentRec.id + '/' + normIdFlow.process(session, i)
        else:
            i = None
        return [i, t.strip()]
        
#    node = parentRec.get_dom(session).xpath(xpath)[0]
    node = parentRec.process_xpath(session, xpath)[0]
    titles = [__processNode(node)]
    for n in node.iterancestors():
        if n.tag == 'dsc':
            continue
        elif n.tag == 'ead':
            break
        else:
            titles.append(__processNode(n))
    
    titles.reverse()
    # Top level id doesn't conform to pattern - is simply the top level
    # record id
    titles[0][0] = parentRec.id
    return titles
    # / _backwalkTitles() ------------------------------------------------


def dataFromRecordXPaths(session, rec, xps, nTerms=1, joiner=u'; '):
    """Extract data from ``rec`` return a single unicode object.
    
    Extract data from ``rec`` using multiple XPaths ``xps`` in priority order.
    Return a maximum of ``nTerms`` matches, joining any multiple values with
    `joiner``. 
    """
    global namespaceUriHash
    data = []
    for xp in xps:
        data.extend(rec.process_xpath(session, xp, namespaceUriHash))
        if len(data) >= nTerms:
            break
    return joiner.join([flattenTexts(d) for d in data[:nTerms]])


def cleverTitleCase(txt):
    global config
    always_lower = config.get('casing', 'always_lower')
    always_upper = config.get('casing', 'always_upper')
    romanNumeralRe = re.compile(config.get('casing', 'roman_numeral_regex'),
                                re.IGNORECASE)
    words = []
    for word in txt.split():
        try:
            if word in always_upper or \
                    romanNumeralRe.match(word):
                # Word in always_upper (i.e. abbreviation) or a roman
                # numeral
                word = word.upper()
            elif word.endswith("'s"):
                # Possessive - don't capitalize trailing s
                word = word[:-2].title() + "'s"
            elif (len(words) == 0 and not
                  (word[0].isdigit() or
                   word.strip('\'"(')[0].isdigit()
                   )
                  ):
                
                # 1st word always capitalized, unless starts with a number
                word = word.title()
            elif (word not in always_lower and word[0].isalpha()):
                # Word not always_lower, and starts with alphabetical char
                word = word.title()
            elif (word.strip('\'"()') not in always_lower and
                  word.strip('\'"()')[0].isalpha()):
                # Word is always_lower, but is in brackets/quotes
                word = word.title()
            elif (len(words) and words[-1][-1] in ":;"):
                # Word following this punctuation always title-cased
                word = word.title()
        except IndexError:
            pass
        words.append(word)
    return u' '.join(words)


def main():
    """Start up a simple app server to serve the application."""
    raise NotImplementedError("cheshire3archives.apps.ead.base contains only "
                              "an Abstract Base Class")


session = Session()
session.environment = "apache"
serv = SimpleServer(session, os.path.join(cheshire3Root,
                                          'configs',
                                          'serverConfig.xml'))
db = serv.get_object(session, 'db_ead')

# App Configuration
config = SafeConfigParser()
# Default configuration
configDefaults = StringIO("""
[brand]
repository_name = Cheshire3 for Archives
repository_link = http://github.com/cheshire3/cheshire3archives
repository_logo = http://cheshire3.org/gfx/c3_black.gif

[icons]
base-url = /img
forward-url = %(base-url)s/forward.png
fast-forward-url = %(base-url)s/fforward.png
rewind-url = %(base-url)s/back.png
fast-rewind-url = %(base-url)s/fback.png
plus-url = %(base-url)s/form_add_row.png
what-url = %(base-url)s/whatisthis.png
folder-open-url = %(base-url)s/folderOpen.png
folder-closed-url = %(base-url)s/folderClosed.png

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
always_upper = BBC,BT,CNN,UK,US,USA
# Regular expression for Roman numerals
roman_numeral_regex = ^M{{0,4}}(CM|CD|D?C{{0,3}})(XC|XL|L?X{{0,3}})(IX|IV|V?I{{0,3}})$

[email]
username = cheshire
host = mail1.liv.ac.uk
port = 25
""".format(
   html_cache_path=resource_filename(
       Requirement.parse('cheshire3archives'),
       'www/apps/ead/html'
   )
))

config.readfp(configDefaults, 'hard-coded')
app_config_path = resource_filename(
    Requirement.parse('cheshire3archives'),
    'www/apps/ead/ead.cfg'
)
config.read([app_config_path])

application = EADWsgiApplication(session, db, config)

# Useful URIs
namespaceUriHash = {
    'dc': 'http://purl.org/dc/elements/1.0',
    'sru_dc': "info:srw/schema/1/dc-v1.1",
    'xhtml': "http://www.w3.org/1999/xhtml",
    'zrx': "http://explain.z3950.org/dtd/2.0/",
    'c3': "http://www.cheshire3.org",
    'rec': "info:srw/extension/2/record-1.1",
    'rec_ah': "http://www.archiveshub.ac.uk/srw/extension/2/record-1.1",
    'rec_c3': "http://www.cheshire3.org/srw/extension/2/record-1.1",
    'rec_c3srw': "http://srw.cheshire3.org/extension/2/record-1.1",
    'rs': "info:srw/extension/2/resultSet-1.1",
    'rs_ah': "http://www.archiveshub.ac.uk/srw/extension/2/resultSet-1.1",
    'rs_c3': "http://www.cheshire3.org/srw/extension/2/resultSet-1.1",
    'rs_c3srw': "http://srw.cheshire3.org/extension/2/resultSet-1.1",
}


if __name__ == "__main__":
    sys.exit(main())
