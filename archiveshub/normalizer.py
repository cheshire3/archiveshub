"""Archives Hub Normalizer Implementations"""

import json

from cheshire3.normalizer import FileAssistedNormalizer


class JSONListFileLookupNormalizer(FileAssistedNormalizer):
    """Normalize by looking up values in a JSON file.
    
    Scan through a JSON file containing a list. If the ``from`` path for
    a particular entry matches the incoming value, normalize to the ``to``
    value.
    """

    _possiblePaths = {
        'json': {
            'docs': ("Path to file containing JSON"),
            'required': True
        }
    }

    _possibleSettings = {
        'from': {
            'docs': ("Field within the JSON to lookup incoming value. "
                     "Configured like an XPath, e.g. "
                     "field/sub-field/sub-sub-field"),
            'required': True
        },
        'to': {
            'docs': ("Field within the JSON to lookup value to normalize to "
                     "(assuming incoming data matches ``from``.) Configured "
                     "like an XPath, e.g. field/sub-field/sub-sub-field"),
           'required': True
        }
    }

    def __init__(self, session, config, parent):
        FileAssistedNormalizer.__init__(self, session, config, parent)
        self._loadJSON(session)
        self.fromField = self.get_setting(session, 'from')
        self.toField = self.get_setting(session, 'to')
        
    def _loadJSON(self, session):
        lines = self._processPath(session, 'json')
        self.json = json.loads('\n'.join(lines))

    def process_string(self, session, data):
        for entry in self.json:
            field = entry
            for part in self.fromField.split('/'):
                try:
                    field = field[part]
                except KeyError:
                    # From field not in this entry
                    break
            else:
                # We found the specified from field
                if data == field:
                    # It matches locate the field to normalize to
                    field = entry
                    for part in self.toField.split('/'):
                        try:
                            field = field[part]
                        except KeyError:
                            break
                    else:
                        # We found the specified from field
                        return field
        # Unable to complete the lookup
        return data
