"""Archives Hub DocumentStore Implementations"""

import os
import sys
import hgapi


from cheshire3.documentStore import DirectoryDocumentStore


class MercurialDocumentStore(DirectoryDocumentStore):
    """Store Objects as files in a Mercurial repository directory.

    An important thing to remember is that files may be added/modified/deleted
    by an external entity.
    """

    repo = None
    defaultUser = "Cheshire3 <info@cheshire3.org>"

    def __init__(self, session, config, parent):
        self.defaultUser = self._getUserString(session)
        DirectoryDocumentStore.__init__(self, session, config, parent)

    def _getUserString(self, session):
        # Return a Mercurial-style user string
        if session.user:
            if session.user.realName:
                userName = session.user.realName
            else:
                userName = session.user.username
            if session.user.email:
                return "{0} <{1}>".format(userName, session.user.email)
            else:
                return userName
        return self.defaultUser

    def _verifyDb(self, session, dbType):
        dbp = self.get_path(session, dbType + "Path")
        if dbType == 'database':
            # Simply the directory in which to store data
            # Ensure that it exists (including any intermediate dirs)
            if not os.path.exists(dbp):
                os.makedirs(dbp)
            userString = self._getUserString(session)
            # Connect to the directory as a Mercurial repository
            self.repo = hgapi.Repo(dbp, user=userString)
            # Check that repository has been initialized
            try:
                self.repo.hg_init()
            except Exception:
                # Probably already a repository
                pass
        else:
            return DirectoryDocumentStore._verify(self, session, dbp)

    def get_dbSize(self, session):
        """Return number of items in storage."""
        databasePath = self.get_path(session, 'databasePath')
        dbSize = 0
        for root, dirs, files in os.walk(databasePath):
            dbSize += len(files)
            # Ignore special .hg directory
            for d in dirs:
                if d == '.hg':
                    dirs.remove(d)
        return dbSize

    def store_document(self, session, doc):
        # Do standard storage for directory based store
        DirectoryDocumentStore.store_document(self, session, doc)
        # Commit new version to the repository
        # Find filename
        normId = self._normalizeIdentifier(session, doc.id)
        filepath = self._getFilePath(session, normId)
        self.repo.hg_add(filepath)
        # Get user
        userString = self._getUserString(session)
        try:
            self.repo.hg_commit('{0} stored {1}'.format(self.id, normId),
                                user=userString,
                                files=[filepath])
        except Exception as e:
            # It's possible that nothing changed
            if 'nothing changed' in e.message:
                pass
            else:
                raise e

    def delete_document(self, session, id_):
        # Do standard delete for directory based store
        DirectoryDocumentStore.delete_document(self, session, id_)
        # Commit new version to the repository
        # Find filename
        normId = self._normalizeIdentifier(session, id_)
        filepath = self._getFilePath(session, normId)
        try:
            self.repo.hg_remove(filepath)
        except Exception as e:
            # It's possible that file was not already untracked
            if 'untracked' in e.message:
                pass
            else:
                raise e
        else:
            # Get user
            userString = self._getUserString(session)
            self.repo.hg_commit('{0} deleted {1}'.format(self.id, normId),
                                user=userString,
                                files=[filepath])
