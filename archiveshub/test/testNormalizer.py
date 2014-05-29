u"""Archives Hub Normalizer Unittests.

Normalizer configurations may be customized by the user. For the purposes of
unittesting, configuration files will be ignored and Normalizer instances
will be instantiated using configurations defined within this testing module,
and tests carried out on those instances using data defined in this module.
"""

try:
    import unittest2 as unittest
except ImportError:
    import unittest

try:
    import json
except ImportError:
    import simplejson as json

from lxml import etree

from cheshire3.test.testNormalizer import FileAssistedNormalizerTestCase

from archiveshub.normalizer import JSONListFileLookupNormalizer


class JSONListFileLookupNormalizerTestCase(FileAssistedNormalizerTestCase):

    @classmethod
    def _get_class(cls):
        return JSONListFileLookupNormalizer

    def _get_config(self):
        return etree.XML('''\
        <subConfig type="normalizer" id="{0.__name__}">
            <objectType>archiveshub.normalizer.{0.__name__}</objectType>
            <paths>
                <path type="json">{1}</path>
            </paths>
            <options>
                <setting type="from">from</setting>
                <setting type="to">to</setting>
            </options>
        </subConfig>'''.format(self._get_class(), self.path))

    def _get_fileLines(self):
        example_json = [
            {
                "from": "bacon",
                "to": "spam"
             },
            {
                "from": "sausage",
                "to": "spam"
             }
        ]
        yield json.dumps(example_json)

    def _get_process_string_tests(self):
        return [
            ("bacon", "spam"),
            ("sausage", "spam"),
            ("spam", "spam"),
            ("eggs", "eggs"),
            ("ham", "ham"),
            ("chips", "chips")
        ]


def load_tests(loader, tests, pattern):
    # Alias loader.loadTestsFromTestCase for sake of line lengths
    ltc = loader.loadTestsFromTestCase
    # Test imported test case on which local tests are based
    suite = ltc(JSONListFileLookupNormalizerTestCase)
    return suite


if __name__ == '__main__':
    tr = unittest.TextTestRunner(verbosity=2)
    tr.run(load_tests(unittest.defaultTestLoader, [], 'test*.py'))
