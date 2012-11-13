#!/bin/env python

import sys
import os
import re
import time

from crypt import crypt

from cheshire3.web.www_utils import *

# Add distro path to Python search path
c3archives_path = os.environ.get('C3ARCHIVESHOME',
                                 os.path.expanduser('~/cheshire3-archives'))
app_path = os.path.join(c3archives_path, 'www', 'apps', 'ead')
sys.path.insert(1, app_path)

# Import customisable variables
from localConfig import *


def main():
    """Build customized pages for EAD search portal."""
    # Read in template page
    tmplPage = read_file(templatePath)
    sys.stdout.write("Building customised pages:\n")
    sys.stdout.flush()
    for pn, title in pageMaps.iteritems():
        # Read in content
        p = read_file(os.path.join(htmlPath, pn))
        np = tmplPage.replace('%CONTENT%', p)
        # Make substitutions
        paramDict['%TITLE%'] = title
        for k, v in paramDict.iteritems():
            np = np.replace(k, v)
        # Write file
        outfp = os.path.join(baseHtmlPath, pn)
        write_file(outfp, np)
        sys.stdout.write("{0}\n".format(outfp))
        sys.stdout.flush()
    return 0


pageMaps = {
    'index.html': 'Search',
    'browse.html': 'Browse Indexes',
    'subject.html': ' Subject Finder',
    #'preview.html':'Preview EAD',
    #'adminhelp.html': 'Administration Help',
    'help.html': 'Help',
    'about.html': 'About Cheshire for Archives Version 3.4'
}

paramDict = {
    'SCRIPT': script,
    '%REP_NAME%': repository_name,
    '%REP_LINK%': repository_link,
    '%REP_LOGO%': repository_logo,
    '%NAVBAR%': ''
}


if __name__ == '__main__':
    sys.exit(main())
