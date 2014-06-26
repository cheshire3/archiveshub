
import os

from tempfile import gettempdir

from pkg_resources import Requirement, resource_filename, get_distribution
from mako.lookup import TemplateLookup
from mako import exceptions
from paste.auth.form import AuthFormHandler
from paste.auth.auth_tkt import AuthTKTMiddleware
from paste.request import construct_url, parse_formvars

from archiveshub.apps.configuration import config


class LoginWSGIMiddleware(AuthFormHandler):
    """Sub-class of ``paste.auth.form.AuthFormHandler`` with minor mods

    Modifications for compatibility with
    ``paste.auth.auth_tkt.AuthTKTMiddleware``.
    """

    def __call__(self, environ, start_response):
        username = environ.get('REMOTE_USER', '')
        if username:
            return self.application(environ, start_response)

        if 'POST' == environ['REQUEST_METHOD']:
            formvars = parse_formvars(environ, include_get_vars=False)
            username = formvars.get('username')
            password = formvars.get('password')
            if username and password:
                if self.authfunc(environ, username, password):
                    environ['AUTH_TYPE'] = 'form'
                    environ['REMOTE_USER'] = username
                    environ['REQUEST_METHOD'] = 'GET'
                    environ['CONTENT_LENGTH'] = ''
                    environ['CONTENT_TYPE'] = ''
                    try:
                        environ['paste.auth_tkt.set_user'](
                            username.encode('utf-8'),
                            tokens='',
                            user_data=''
                        )
                    except KeyError:
                        # Not AuthTKT
                        pass
                    del environ['paste.parsed_formvars']
                    return self.application(environ, start_response)

        content = self.template % construct_url(environ)
        start_response("200 OK", [('Content-Type', 'text/html'),
                                  ('Content-Length', str(len(content)))])
        return [content]


def get_login_form():
    global templateLookup, defaultContext
    template = templateLookup.get_template('auth/login.html')
    return template.render(**defaultContext)


def get_password_checker(check_password):
    """Password check function factory.

    Return a callable with signature expected by AuthFormHandler.

    :arg check_password: function to check username, password pair
    :type app: callable
    """

    def password_checker(environ, username, password):
        if check_password(username, password):
            environ['REMOTE_USER'] = username
            return True
        return False

    return password_checker


def make_form_authenticated(app, check_password, **kwargs):
    """Middleware factory to return HTML+Cookie authenticated app.

    :arg app: WSGIApplication to be wrapped in AuthN middleware
    :type app: callable
    :arg check_password: function to check username, password pair
    :type app: callable
    """
    wrapped = AuthTKTMiddleware(
        LoginWSGIMiddleware(
            app,
            get_password_checker(check_password),
            template=get_login_form()
        ),
        secret=kwargs.pop('secret', 'test'),
        cookie_name=kwargs.pop('cookie_name', 'archiveshub_auth'),
        **kwargs
    )
    return wrapped


ah_pkg = Requirement.parse('archiveshub')

app_config_path = resource_filename(
    ah_pkg,
    'www/ead/ead.ini'
)
config.read([app_config_path])


template_dir = resource_filename(
    ah_pkg,
    'www/ead/tmpl'
)

mod_dir = os.path.join(gettempdir(),
                       'mako_modules',
                       'archiveshub',
                       'apps',
                       'ead'
                       )

templateLookup = TemplateLookup(directories=[template_dir],
                                output_encoding='utf-8',
                                input_encoding='utf-8',
                                module_directory=mod_dir,
                                strict_undefined=False
                                )

defaultContext = {
    'version': get_distribution("archiveshub").version,
    'config': config,
    'BASE': '/'
}
