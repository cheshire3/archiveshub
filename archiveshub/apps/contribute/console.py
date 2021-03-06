"""EAD Contributor Console WSGI Application."""

from __future__ import with_statement

import os
import sys
import webbrowser

# Site packages

try:
    import uwsgi
except ImportError:
    uwsgi = None

from cheshire3.document import StringDocument
from cheshire3.exceptions import ObjectDoesNotExistException

from archiveshub.deploy.utils import WSGIAppArgumentParser
from ..ead.auth import make_form_authenticated
from ..ead.base import EADWsgiApplication, config, session, db
from .utils import (
    get_userDocumentStore,
    get_userInstitutionDocumentStoreId,
    get_userInstitutionId,
    get_userInstitutionName
)


class EADContributeWsgiApplication(EADWsgiApplication):

    ALLOWED_METHODS = ['DELETE', 'GET', 'HEAD', 'POST', 'PUT']

    def __init__(self, config, session, database):
        # Constructor method
        super(EADContributeWsgiApplication, self).__init__(
            config,
            session,
            database
        )
        # Fetch Logger
        self.logger = database.get_object(
            session,
            'consoleTransactionLogger'
        )
        self.docStoreStore = database.get_object(
            session,
            'documentStoreConfigStore'
        )

    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        # Prepare application to handle a new request
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
        script = '/contribute'
        self.defaultContext['SCRIPT'] = script
        # Set the base URL of this family of apps
        self.defaultContext['BASE'] = script

    def delete(self):
        name = self.request.path_info.strip(' /')
        # Delete document
        docStore = get_userDocumentStore(self.session.user.username)
        id_ = docStore.outIdNormalizer.process_string(session, name)
        docStore.delete_document(session, id_)
        self.response.status = "204 Deleted"
        if uwsgi:
            uwsgi.reload()
        return ''

    def get(self):
        try:
            path = self.request.path_info.strip('/')
            if self.request.path_info_peek() in ['css', 'img', 'js']:
                static_iter = self._static_content(path)
                contentlen = sum([len(d)
                                  for d
                                  in static_iter
                                  ])
                if contentlen:
                    return ''.join(static_iter)
                else:
                    self.response.status = 404
                    return self._render_template(
                        'fail/404.html',
                        resource=path
                    )

            form = self._get_params()
            operation = form.get('operation', None)
            if operation is None:
                # Filename based?
                operation = os.path.splitext(path.split('/')[-1])[0]
            contributorDocStore = get_userDocumentStore(session.user.username)
            if contributorDocStore is None:
                return self._render_template(
                    'console/fail/noDocStore.html',
                )
            # Check operation and act accordingly
            if not operation or operation == 'index':
                return self._render_template(
                    'console/index.html',
                    contributorStore=contributorDocStore
                )
            else:
                id_ = contributorDocStore.outIdNormalizer.process_string(
                    session,
                    path
                )
                try:
                    doc = contributorDocStore.fetch_document(session, id_)
                except ObjectDoesNotExistException:
                    self.request.status_code = 404
                    return self._render_template(
                        'fail/404.html',
                        resource=self.request.path_info
                    )
                if operation == 'raw':
                    self.response.content_type = 'application/xml'
                    self.response.content_encoding = 'utf-8'
                    return doc.get_raw(session)
                return self._render_template(
                    'console/view.html',
                    doc=doc,
                    contributorStore=contributorDocStore
                )
        finally:
            try:
                self.logger.flush(self.session, 20, self.request.remote_addr)
            except ValueError:
                # It's possible nothing was logged for this remote user
                pass

    def post(self):
        name = self.request.path_info.strip(' /')
        if not name:
            # Accidental re-submit of login form?
            # Return index page
            return self.get()
        data = self.request.body
        # Create a Document
        doc = StringDocument(
            data,
            creator=self.session.user.username,
            filename=name,
            tagName="ead"
        )
        # TODO: Validate
        # Store document
        docStore = get_userDocumentStore(self.session.user.username)
        doc.id = id_ = docStore.outIdNormalizer.process_string(session, name)
        docStore.store_document(session, doc)
        self.response.status = "201 Created"
        if uwsgi:
            uwsgi.reload()
        return ""


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
