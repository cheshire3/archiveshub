"""Archives Hub Normalizer Implementations"""

try:
    import json
except ImportError:
    import simplejson as json

from collections import OrderedDict

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
        self.fromField = self.get_setting(session, 'from')
        self.toField = self.get_setting(session, 'to')
        self._loadJSON(session)

    def _loadJSON(self, session):
        lines = self._processPath(session, 'json')
        json_list = json.loads('\n'.join(lines))
        self.lookup = OrderedDict()
        for entry in json_list:
            key = entry
            for part in self.fromField.split('/'):
                try:
                    key = key[part]
                except KeyError:
                    # From field not in this entry
                    break
            else:
                # We found the specified `from` field
                # Find the corresponding `to` field
                value = entry
                for part in self.toField.split('/'):
                    try:
                        value = value[part]
                    except KeyError:
                        break
                else:
                    # We found the specified `from` field
                    self.lookup[key] = value

    def process_string(self, session, data):
        try:
            return self.lookup[data]
        except KeyError:
            return data
