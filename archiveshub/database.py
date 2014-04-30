"""Archives Hub Database Implementation(s)."""

from cheshire3.baseObjects import Database, Index, ProtocolMap
from cheshire3.database import SimpleDatabase
from cheshire3.exceptions import (
    ConfigFileException,
    ObjectDoesNotExistException
)
from cheshire3.recordStore import BdbRecordIter


class ArchivesHubDatabase(SimpleDatabase):
    """Archives Hub Database Implementation."""

    def __init__(self, session, config, parent=None):
        SimpleDatabase.__init__(self, session, config, parent=None)
        # Now check for configStore objects
        for csid in self._includeConfigStores:
            try:
                confStore = self.get_object(session, csid)
            except ObjectDoesNotExistException:
                try:
                    self.log_error(
                        session,
                        "Failed to get ConfigStore {0}".format(csid)
                    )
                except AttributeError:
                    pass
            else:
                for objrec in BdbRecordIter(session, confStore):
                    # Do something with object
                    objrec = confStore.fetch_record(session, objrec.id)
                    node = objrec.get_dom(session)
                    nid = objrec.id
                    # Add everything to subConfigs
                    self.subConfigs[nid] = node
                    # Handle special cases
                    msg = ("Object must have a type attribute: %s  -- "
                           "in configStore %s" % (nid, csid)
                           )
                    try:
                        ntype = objrec.process_xpath(session, './@type')[0]
                    except IndexError:
                        self.log_error(session, msg)
                        raise ConfigFileException(msg)
                    if ntype == 'index':
                        self.indexConfigs[nid] = node
                    elif ntype == 'protocolMap':
                        self.protocolMapConfigs[nid] = node
                    elif ntype == 'database':
                        self.databaseConfigs[nid] = node
                    elif not ntype:
                        self.log_error(session, msg)
                        raise ConfigFileException(msg)
