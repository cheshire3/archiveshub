"""Abstract Base Class for EAD WSGI Applications."""

import sys

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


def main():
    """Start up a simple app server to serve the SRU application."""
    raise NotImplementedError('ead.py contains an Abstract Base Class')


application = EADWsgiApplication()


if __name__ == "__main__":
    sys.exit(main())
