"""""Archives Hub Selector Implementations."""

from cheshire3.baseObjects import Selector


class ParentIdentifierSelector(Selector):
    """Optimized Selector for collection identifier."""

    def process_record(self, session, record):
        "Extract the collection identifier"
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
                return [record.id]
        _, parentId = parentId.split('/', 1)
        return [parentId]
