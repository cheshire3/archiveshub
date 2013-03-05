"""Abstract Base Class for EAD WSGI Applications."""

import os
import sys
import mimetypes
import traceback

from pkg_resources import Requirement, get_distribution
from pkg_resources import resource_filename, resource_stream
from ConfigParser import SafeConfigParser
# Mako
from mako.template import Template
from mako.lookup import TemplateLookup
from mako import exceptions
from tempfile import gettempdir

from cheshire3.baseObjects import Session
import cheshire3.exceptions as c3errors
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
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
        self.resultSetStore = self.database.get_object(session,
                                                       'eadResultSetStore')
        template_dir = resource_filename(
            Requirement.parse('cheshire3archives'),
            'www/apps/ead/tmpl'
        )
        mod_dir = os.path.join(gettempdir(), 'mako_modules')
        
        self.templateLookup = TemplateLookup(directories=[template_dir],
                                             output_encoding='utf-8',
                                             module_directory=mod_dir,
                                             strict_undefined=True)
        self.globalReplacements = {
            'version': get_distribution("cheshire3archives").version,
        }
        self.globalReplacements.update(config.defaults())

    def _setUp(self, environ):
        # Prepare application to handle a new request
        self.response_headers = []
        self.environ = environ
        self.htmlTitle = []
        self.htmlNav = []
        self.globalReplacements['SCRIPT'] = environ.get("SCRIPT_NAME")

    def _log(self, lvl, msg):
        print >> self.environ['wsgi.errors'], msg

    def _static_content(self, path):
        # Serve static content, CSS, images JavaScript etc.
        try:
            stream =  resource_stream(
                Requirement.parse('cheshire3archives'),
                'www/htdocs/ead/{0}'.format(path)             
            )
        except IOError:
            if path.startswith('ead/'):
                return self._static_content(path[3:])
            return []
        else:
            mType, encoding = mimetypes.guess_type(path)
            if mType is not None:
                self.response_headers.append(('Content-Type', mType))
            if encoding is not None:
                self.response_headers.append(('Content-Encoding', encoding))
            return stream

    def _render_template(self, template_name, **kwargs):
        try:
            template = self.templateLookup.get_template(template_name)
            d = self.globalReplacements.copy()
            d.update(kwargs)
            return template.render(**d)
        except:
            
            return exceptions.html_error_template().render()

    def _handle_error(self):
        self.htmlTitle.append('Error')
        cla, exc, trbk = sys.exc_info()
        excName = cla.__name__
        try:
            excArgs = exc.__dict__["args"]
        except KeyError:
            excArgs = str(exc)
        excTb = traceback.format_tb(trbk, 100)
        # TODO: add logging
        #self.log('*** {0}: {1}'.format(excName, excArgs))
        #self.logExc('{0}: {1}\n{2}'.format(excName, excArgs, '\n'.join(excTb)))
        yield html_encode(excName)
        yield html_encode(excArgs)
        for line in excTb:
            yield html_encode(line)
            yield '<br/>\n'
#        return '''\
#        <div id="single">
#          <p class="error">An error occurred while processing your request.
#            <br/>The message returned was as follows:
#          </p>
#          <code>{0}: {1}</code>
#          <p>
#            <strong>
#              Please try again, or contact the system administrator if this 
#              problem persists.
#            </strong>
#          </p>
#          <p>Debugging Traceback: 
#            <a href="#traceback" class="jstoggle-text">[ hide ]</a>
#          </p>
#          <div id="traceback" class="jshide">{2}</div>
#        </div> <!-- /single -->
#        '''.format(excName, excArgs, excTb).split('\n')

    def _fetch_record(self, session, recid):
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

    def _fetch_resultSet(self, session, rsid):
        return self.resultSetStore.fetch_resultSet(session, rsid)

    def _textFromRecord(self, rec):
        # Return a text representation of the Record
        global namespaceUriHash
        txr = self.database.get_object(self.session, "textTxr")
        doc = txr.process_record(session, rec)
        docString = doc.get_raw(session)
        # Resolve link to parent if a component
        try:
            parentId = rec.process_xpath(session,
                                         '/c3:component/@c3:parent', 
                                         namespaceUriHash)[0]
        except IndexError:
            return docString
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
            txt = ['In: {0}'.format(parentTitle),
                   '-' * 78,
                   '',
                   docString
                   ]
            return '\n'.join(txt)


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
configDefaults= {
    'repository_name': "Cheshire3 for Archives",
    'repository_link': "http://github.com/cheshire3/cheshire3archives",
    'repository_logo': "http://cheshire3.org/gfx/c3_black.gif",
}
config = SafeConfigParser(defaults=configDefaults)

application = EADWsgiApplication(session, db, config)

# Useful URIs
namespaceUriHash = {
    'dc': 'http://purl.org/dc/elements/1.0',
    'sru_dc': "info:srw/schema/1/dc-v1.1",
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
