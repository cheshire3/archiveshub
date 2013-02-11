"""Abstract Base Class for EAD WSGI Applications."""

import sys
import traceback

from cheshire3.web.www_utils import html_encode

# Local imports
from localConfig import *

class EADWsgiApplication(object):
    
    def __init__(self):
        self.htmlTitle = []
        self.htmlNav = []
        self.globalReplacements = {'%REP_NAME%': repository_name,
                                   '%REP_LINK%': repository_link,
                                   '%REP_LOGO%': repository_logo,
                                   '<br>': '<br/>',
                                   '<hr>': '<hr/>'
                                   }

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
        excName = html_encode(excName)
        excArgs = html_encode(excArgs)
        
        excTb = '<br/>\n'.join([html_encode(line) for line in excTb])
        return '''\
        <div id="single">
          <p class="error">An error occurred while processing your request.
            <br/>The message returned was as follows:
          </p>
          <code>{0}: {1}</code>
          <p>
            <strong>
              Please try again, or contact the system administrator if this 
              problem persists.
            </strong>
          </p>
          <p>Debugging Traceback: 
            <a href="#traceback" class="jstoggle-text">[ hide ]</a>
          </p>
          <div id="traceback" class="jshide">{2}</div>
        </div> <!-- /single -->
        '''.format(excName, excArgs, excTb).split('\n')

def main():
    """Start up a simple app server to serve the SRU application."""
    raise NotImplementedError('ead.py contains an Abstract Base Class')


application = EADWsgiApplication()


if __name__ == "__main__":
    sys.exit(main())
