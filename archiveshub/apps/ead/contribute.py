"""EAD Contributor Console WSGI Application."""

from __future__ import with_statement

import inspect
import os
import sys
import webbrowser

# Site packages

from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.deploy.utils import WSGIAppArgumentParser
from .auth import make_form_authenticated
from .base import EADWsgiApplication, config, session, db


class EADContributeWsgiApplication(EADWsgiApplication):

    ALLOWED_METHODS = ['DELETE', 'GET', 'HEAD', 'POST', 'PUT']

    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        self._setUp(environ)
        try:
            func = getattr(self, self.request.method.lower())
        except AttributeError:
            if self.request.method.upper() == "HEAD":
                # Do a GET but don't attach the body
                _ = self.get()
            else:
                # Unsupported method
                self.response.status = "405 Method Not Allowed"
                self.response.allow = self.ALLOWED_METHODS
        else:
            body = func()
            if body:
                self.response.body = body
        return self.response(environ, start_response)

    def _setUp(self, environ):
        super(EADContributeWsgiApplication, self)._setUp(environ)
        session.user = authStore.fetch_object(
            session,
            self.request.remote_user
        )

    def get(self):
        global db, session, authStore
        try:
            # Prepare application to handle a new request
            path = self.request.path_info.strip('/')
            form = self._get_params()
            operation = form.get('operation', None)
            if operation is None:
                # Filename based?
                operation = os.path.splitext(path.split('/')[-1])[0]
            # Check operation and act accordingly
            if not operation or operation == 'index':
                configStore = db.get_object(
                    session,
                    'documentStoreConfigStore'
                )
                docStoreId = self._get_userInstitutionDocumentStoreId(
                    session.user.username
                )
                if docStoreId is None:
                    institution_name = self._get_userInstitutionName(
                        session.user.username
                    )
                    docStoreId = '{0}DocumentStore'.format(institution_name)
                try:
                    contributorStore = configStore.fetch_object(
                        session,
                        docStoreId
                    )
                except ObjectDoesNotExistException:
                    return self._render_template(
                        'console/fail/noDocStore.html',
                    )
                else:
                    return self._render_template(
                        'console/index.html',
                        contributorStore=contributorStore
                    )
            else:
                self.request.status_code = 404
                return self._render_template(
                    'fail/404.html',
                    resource=self.request.path_info
                )
        finally:
            try:
                self.logger.flush(self.session, 20, self.request.remote_addr)
            except ValueError:
                # It's possible nothing was logged for this remote user
                pass

    def _get_userInstitutionDocumentStoreId(self, username):
        global authStore
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        instStore = db.get_object(session, 'institutionStore')
        instRec = instStore.fetch_record(session, authinst)
        try:
            return instRec.process_xpath(session, '//documentStore/text()')[0]
        except IndexError:
            return None

    def _get_userInstitutionId(self, username):
        # Return the institution id of the user performing the operation
        global authStore
        sqlQ = ("SELECT institutionid "
                "FROM hubAuthStore_linkauthinst "
                "WHERE hubAuthStore=%s")
        res = authStore._query(sqlQ, (username,))
        if len(res) > 1:
            # We have two templates with the same id - should never happen
            return None
        else:
            return res[0][0]

    def _get_userInstitutionName(self, username):
        global authStore
        # Get the institution of the user performing the operation
        authinst = self._get_userInstitutionId(session.user.username)
        instStore = db.get_object(session, 'institutionStore')
        instRec = instStore.fetch_record(session, authinst)
        return instRec.process_xpath(session, '//name/text()')[0]


def check_password(username, password):
    global db, session, authStore
    try:
        u = session.user = authStore.fetch_object(session, username)
    except ObjectDoesNotExistException:
        return None
    if u.check_password(session, password):
        return True
    else:
        return False


def main(argv=None):
    """Start up a simple app server to serve the application."""
    global argparser, application
    from wsgiref.simple_server import make_server
    if argv is None:
        args = argparser.parse_args()
    else:
        args = argparser.parse_args(argv)
    httpd = make_server(args.hostname, args.port, application)
    url = "http://{0}:{1}".format(args.hostname, args.port)
    if args.browser:
        webbrowser.open(url)
        print ("Hopefully a new browser window/tab should have opened "
               "displaying the application.")
        print "If not, you should be able to access the application at:"
    else:
        print "You should be able to access the application at:"

    print url
    return httpd.serve_forever()


authStore = db.get_object(session, 'hubAuthStore')

application = make_form_authenticated(
    EADContributeWsgiApplication(config, session, db),
    check_password,
    cookie_name='archiveshub_authn_contribute',
    httponly=True,
    include_ip=True,
    logout_path='logout'
)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == "__main__":
    sys.exit(main())