#!/home/cheshire/install/bin/python
# -*- coding: utf-8 -*-
# Script:    test.py
# Date:      21 November 2013
# Copyright: &copy; University of Liverpool 2011
# Author(s): JH - John Harrison <john.harrison@liv.ac.uk>
# Language:  Python
#
u"""Test a Cheshire3 database of EAD finding aid documents.

Includes building, indexing, and user creation and editing
Part of Cheshire for Archives v3

Usage: test.py
or
python test.py

"""

import os
import sys
import unittest

from lxml import etree

cheshirePath = os.environ.get('C3HOME', '/home/cheshire/')
sys.path.insert(1, os.path.join(cheshirePath, 'cheshire3', 'code'))

from cheshire3.baseObjects import Session
from cheshire3.server import SimpleServer
import cheshire3.cqlParser as cql


class Cheshire3TestCase(unittest.TestCase):
    """Abstract Base Class for testing a Cheshire3 Object."""

    def setUp(self):
        self.session = Session()
        fp = os.path.join(cheshirePath, 'cheshire3', 'configs', 'serverConfig.xml')
        self.server = SimpleServer(self.session, fp)


class HighlightingTxrTestCase(Cheshire3TestCase):
    """Test Case Class for testing the Highlighting Transformer."""

    def setUp(self):
        Cheshire3TestCase.setUp(self)
        self.database = self.server.get_object(self.session, 'db_ead')
        self.session.database = self.database.id
        self.txr = self.database.get_object(self.session, 'highlightTxr')
        self.recordStore = self.database.get_object(self.session, 'recordStore')
        query = self._get_query('''cql.anywhere all/relevant/proxinfo "john sampson"
        or/relevant/proxinfo 
        dc.description all/relevant/proxinfo "john sampson" 
        or/relevant/proxinfo 
        dc.title all/relevant/proxinfo "john sampson"''')
        self.resultSet = self.database.search(self.session, query) 

    def _get_query(self, data, format='cql', codec=None, db=None):
        if db is None:
            db = self.database
        queryFactory = db.get_object(self.session, 'defaultQueryFactory')
        return queryFactory.get_query(self.session, data, format=format, codec=codec, db=db)

    def test_01_without_proxinfo(self):
        "Output IS NOT affected in absence of proxInfo"
        session = self.session
        txr = self.txr
        for i, rec in enumerate(self.recordStore):
#            if i > 49:
#                break
            doc = txr.process_record(session, rec)
            self.assertEqual(rec.get_xml(session), 
                             doc.get_raw(session),
                             msg="highlightTxr alters record text even when no proxInfo available"
                             )

    def test_02_has_proxinfo(self):
        "ResultSetItems have proxInfo"
        for rsi in self.resultSet:
            self.assertTrue(rsi.proxInfo is not None and len(rsi.proxInfo) > 0)

    def test_03_with_proxinfo(self):
        "Output IS affected in presence of proxInfo"
        session = self.session
        txr = self.txr
        for rsi in self.resultSet:
            rec = rsi.fetch_record(session)
            recXml = rec.get_xml(session)
            doc = txr.process_record(session, rec)
            self.assertNotEqual(recXml,
                                doc.get_raw(session),
                                 msg="highlightTxr not highlighting {0}".format(rec.id)
                                )

    def test_04_text_unaffected(self):
        "Output plain text order is not altered"
        session = self.session
        txr = self.txr
        for rsi in self.resultSet:
            rec = rsi.fetch_record(session)
            recString = etree.tostring(rec.get_dom(self.session), method="text", encoding="utf-8")
            doc = txr.process_record(session, rec)
            docstring = doc.get_raw(session)
            et = etree.fromstring(docstring)
            self.assertEqual(recString,
                             etree.tostring(et, method="text", encoding="utf-8"), 
                             msg="highlightTxr mangles record text when highlighting {0}".format(rec.id)
                             )


if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(HighlightingTxrTestCase))
    unittest.TextTestRunner(verbosity=2).run(suite)
