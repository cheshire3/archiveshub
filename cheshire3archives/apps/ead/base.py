"""Abstract Base Class for EAD WSGI Applications."""

import os
import sys
import traceback


from cheshire3.baseObjects import Session
import cheshire3.exceptions as c3errors
from cheshire3.internal import cheshire3Root
from cheshire3.server import SimpleServer
from cheshire3.web.www_utils import html_encode
from ConfigParser import SafeConfigParser


class EADWsgiApplication(object):
    
    def __init__(self, session, database, config):
        self.session = session
        self.database = database
        self.queryFactory = self.database.get_object(session,
                                                     'defaultQueryFactory')
        self.globalReplacements = {
#            '%REP_NAME%': repository_name,
#            '%REP_LINK%': repository_link,
#            '%REP_LOGO%': repository_logo,
            '<br>': '<br/>',
            '<hr>': '<hr/>'
        }
    
    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        self.response_headers = []
        self.htmlTitle = []
        self.htmlNav = []

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


def main():
    """Start up a simple app server to serve the SRU application."""
    raise NotImplementedError("cheshire3archives.apps.ead.base contains only"
                              "an Abstract Base Class")


session = Session()
session.environment = "apache"
serv = SimpleServer(session, os.path.join(cheshire3Root,
                                          'configs',
                                          'serverConfig.xml'))
db = serv.get_object(session, 'db_ead')
config = SafeConfigParser()
application = EADWsgiApplication(session, db, config)


if __name__ == "__main__":
    sys.exit(main())
