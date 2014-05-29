"""Archives Hub Workflow Implementations"""

from cheshire3.baseObjects import Workflow, Database, Server


class CollectionFromComponentWorkflow(Workflow):
    """Optimized Workflow for fetching a Collection from a Component.

    Given a Cheshire3 component Record, fetch and return the Record for its
    parent.
    """

    def process(self, session, record):
        # Get RecordStore and identifier of parent record
        try:
            parentId = record.process_xpath(session, '/c3component/@parent')[0]
        except IndexError:
            try:
                parentId = record.process_xpath(
                    session,
                    '/c3:component/@c3:parent',
                    maps={'c3': "http://www.cheshire3.org/schemas/component/"}
                )[0]
            except IndexError:
                # Not a component!
                return record
        recStoreId, parentId = parentId.split('/', 1)
        # Get RecordStore object
        if isinstance(self.parent, Database):
            db = self.parent
        elif isinstance(self.parent, Server) and session.database:
            db = self.parent.get_object(session, session.database)
        elif (
                session.server and
                isinstance(session.server, Server) and
                session.database
        ):
            db = session.server.get_object(session, session.database)
        elif not session.server:
            raise ValueError("No session.server")
        else:
            raise ValueError("No session.database")
        recStore = db.get_object(session, recStoreId)
        # Fetch parent record
        return recStore.fetch_record(session, parentId)
