u"""Cheshire3 DocumentStore Unittests.

DocumentStore configurations may be customized by the user. For the purposes of
unittesting, configuration files will be ignored and DocumentStore instances
will be instantiated using configurations defined within this testing module, 
and tests carried out on those instances using data defined in this module.
"""

import hgapi

try:
    import unittest2 as unittest
except ImportError:
    import unittest


from datetime import datetime

from cheshire3.document import Document, StringDocument
from archiveshub.documentStore import MercurialDocumentStore
from cheshire3.exceptions import ObjectAlreadyExistsException,\
                                 ObjectDoesNotExistException,\
                                 ObjectDeletedException
from cheshire3.test.testDocumentStore import DirectoryDocumentStoreTestCase


class MercurialDocumentStoreTestCase(DirectoryDocumentStoreTestCase):
    "Tests for Mercurial repository based DocumentStore."

    @classmethod
    def _get_class(cls):
        return MercurialDocumentStore

    def test_repository(self):
        self.assertIsInstance(self.testObj.repo, hgapi.Repo)

    def test_store_data(self):
        "Check that Doc is stored without corruption to copy in memory."
        theoreticalSize = 0
        for inDoc in self._get_test_docs():
            # Store the Document
            outDoc = self.testObj.create_document(self.session, inDoc)
            theoreticalSize += 1
            # Check that Store returns the correct size
            self.assertEqual(self.testObj.get_dbSize(self.session),
                             theoreticalSize)
            # Check that returned doc is unaltered
            self.assertEqual(outDoc.get_raw(self.session),
                             inDoc.get_raw(self.session),
                             u"Returned document content not as expected")
            # Check that Document has been added+committed to the repository
            last_msg = self.testObj.repo[-1].desc
            self.assertTrue("stored {0}".format(outDoc.id) in last_msg)

    def test_storeDeleteFetch_data(self):
        "Check that Document is deleted."
        theoreticalSize = 0
        for inDoc in self._get_test_docs():
            # Store the Document
            inDoc = self.testObj.create_document(self.session, inDoc)
            theoreticalSize += 1
            # Check that Store returns the correct size
            self.assertEqual(self.testObj.get_dbSize(self.session),
                             theoreticalSize)
            # Fetch the Document
            outDoc = self.testObj.fetch_document(self.session, inDoc.id)
            # Check that returned doc is unaltered
            self.assertEqual(outDoc.get_raw(self.session),
                             inDoc.get_raw(self.session),
                             u"Returned document content not as expected")
            # Delete the Document
            self.testObj.delete_document(self.session, inDoc.id)
            theoreticalSize -= 1
            # Check that Store returns the correct size
            self.assertEqual(self.testObj.get_dbSize(self.session),
                             theoreticalSize)
            # Check that deleted data no longer exists / evaluates as false
            self.assertRaises(ObjectDoesNotExistException,
                              self.testObj.fetch_document,
                              self.session, inDoc.id)
            # Check that Document has been deleted to the repository
            last_msg = self.testObj.repo[-1].desc
            self.assertTrue("deleted {0}".format(outDoc.id) in last_msg)


def load_tests(loader, tests, pattern):
    # Alias loader.loadTestsFromTestCase for sake of line lengths
    ltc = loader.loadTestsFromTestCase
    # Test imported test case on which local tests are based
    suite = ltc(DirectoryDocumentStoreTestCase)
    suite.addTests(ltc(MercurialDocumentStoreTestCase))
    return suite


if __name__ == '__main__':
    tr = unittest.TextTestRunner(verbosity=2)
    tr.run(load_tests(unittest.defaultTestLoader, [], 'test*.py'))
