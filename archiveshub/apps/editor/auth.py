
import os

from tempfile import gettempdir

from pkg_resources import Requirement, resource_filename, get_distribution
from mako.lookup import TemplateLookup
from mako import exceptions
from paste.auth.form import AuthFormHandler
from paste.auth.cookie import AuthCookieHandler

from archiveshub.apps.configuration import config


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
    wrapped = AuthCookieHandler(
        AuthFormHandler(
            app,
            get_password_checker(check_password),
            template=get_login_form()
        ),
        cookie_name=kwargs.get('cookie_name', 'archiveshub_auth'),
        secret='test'
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


AUTH_FORM_TEMPLATE = ''''''