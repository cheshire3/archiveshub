"""Archives Hub Editor Administration Application."""

from __future__ import absolute_import

import sys

from mod_python_wsgi.wrap import ModPythonWSGIApp

from archiveshub.deploy.utils import WSGIAppArgumentParser
from archiveshub.apps.editor.hubeditAdminHandler import (
    handler,
    check_password
)

from .auth import make_form_authenticated


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
        import webbrowser
        webbrowser.open(url)
        print ("Hopefully a new browser window/tab should have opened "
               "displaying the application.")
        print "If not, you should be able to access the application at:"
    else:
        print "You should be able to access the application at:"

    print url
    return httpd.serve_forever()


application = make_form_authenticated(
    ModPythonWSGIApp(handler),
    check_password,
    cookie_name='archiveshub_authn_admin',
    httponly=True,
    include_ip=True,
    logout_path='logout'
)

# Set up argument parser
argparser = WSGIAppArgumentParser(
    conflict_handler='resolve',
    description=__doc__.splitlines()[0]
)

if __name__ == '__main__':
    sys.exit(main())
