"""EAD Contributor Utilities."""

from cheshire3.exceptions import ObjectDoesNotExistException

from ..ead.base import session, db


def get_userDocumentStore(username):
    global docStoreStore, session
    docStoreId = get_userInstitutionDocumentStoreId(
        username
    )
    # Disabled automatic guess of Mercurial folder - force selection in
    # Admin console
    # if docStoreId is None:
    #     institution_name = self._get_userInstitutionName(
    #         username
    #     )
    #     docStoreId = '{0}DocumentStore'.format(institution_name)
    try:
        return docStoreStore.fetch_object(session, docStoreId)
    except ObjectDoesNotExistException:
        return None


def get_userInstitutionDocumentStoreId(username):
    # Get the institution of the user performing the operation
    global db, session
    authinst = get_userInstitutionId(username)
    instStore = db.get_object(session, 'institutionStore')
    instRec = instStore.fetch_record(session, authinst)
    try:
        return instRec.process_xpath(session, '//documentStore/text()')[0]
    except IndexError:
        return None


def get_userInstitutionId(username):
    # Return the institution id of the user performing the operation
    global db, session
    sqlQ = ("SELECT institutionid "
            "FROM hubAuthStore_linkauthinst "
            "WHERE hubAuthStore=%s")
    authStore = db.get_object(session, 'hubAuthStore')
    res = authStore._query(sqlQ, (username,))
    if len(res) > 1:
        # We have two templates with the same id - should never happen
        return None
    else:
        return res[0][0]


def get_userInstitutionName(username):
    global db, session
    # Get the institution of the user performing the operation
    authinst = get_userInstitutionId(username)
    instStore = db.get_object(session, 'institutionStore')
    instRec = instStore.fetch_record(session, authinst)
    return instRec.process_xpath(session, '//name/text()')[0]



docStoreStore = db.get_object(session, 'documentStoreConfigStore')
