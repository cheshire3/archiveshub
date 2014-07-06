"""EAD Contributor Console WSGI Application."""

from __future__ import with_statement

import os
import sys
import webbrowser

# Site packages

from archiveshub.deploy.utils import WSGIAppArgumentParser
from archiveshub.apps.ead.base import EADWsgiApplication
from archiveshub.apps.ead.base import config, session, db


class EADContributeWsgiApplication(EADWsgiApplication):

    def __call__(self, environ, start_response):
        # Method to make instances of this class callable
        global db, session
        try:
            # Prepare application to handle a new request
            self._setUp(environ)
            path = self.request.path_info.strip('/')
            form = self._get_params()
            operation = form.get('operation', None)
            if operation is None:
                # Filename based?
                operation = os.path.splitext(path.split('/')[-1])[0]
            # Check operation and act accordingly
            if not operation or operation == 'index':
                contributorStore = db.get_object(
                    session,
                    'documentStoreConfigStore'
                )
                self.response.body = self._render_template(
                    'console/index.html',
                    contributorStore=contributorStore
                )

            return self.response(environ, start_response)
        finally:
            try:
                self.logger.flush(self.session, 20, self.request.remote_addr)
            except ValueError:
                # It's possible nothing was logged for this remote user
                pass


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


application = EADContributeWsgiApplication(config, session, db)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)


if __name__ == "__main__":
    sys.exit(main())