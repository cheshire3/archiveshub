"""Archives Hub PreParser Implementations"""

import re

from cheshire3.document import StringDocument
from cheshire3.preParser import SgmlPreParser


class EADSgmlPreParser(SgmlPreParser):
    
    def __init__(self, session, config, parent):
        SgmlPreParser.__init__(self, session, config, parent)
        self.doctype_re = (re.compile('<!DOCTYPE\s+?(.+?)["\'](.+?)["\']\s*>'))

    def process_document(self, session, doc):
        txt = doc.get_raw(session)
        txt = txt.replace('\n', ' ')
        txt = txt.replace('\r', ' ')
        for x in range(9, 14):
            txt = txt.replace('&#%d;' % (x), ' ')
        txt = self.doctype_re.sub('', txt)
        for e in self.entities.keys():
            txt = txt.replace("&%s;" % (e), self.entities[e])
        txt = self.amp_re.sub(self._loneAmpersand, txt)
        txt = txt.replace('&<', '&amp;<')
        txt = self.attr_re.sub(self._attributeFix, txt)
        txt = self.elem_re.sub(self._lowerElement, txt)
        for t in self.emptyTags:
            empty_re = re.compile('<(%s( [^>/]+)?)[\s/]*>' % t)
            txt = empty_re.sub(self._emptyElement, txt)
        # Strip processing instructions
        # Protect XML declaration if present
        first_pi = self.pi_re.search(txt)
        txt = self.pi_re.sub('', txt)
        if first_pi and first_pi.group(0).startswith('<?xml '):
           txt = first_pi.group(0) + '\n' + txt
        return StringDocument(txt, self.id, doc.processHistory,
                              mimeType=doc.mimeType, parent=doc.parent,
                              filename=doc.filename)
