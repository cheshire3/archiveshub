"""Abstract Base Class for Archives Hub WSGI Applications."""

import os

from pkg_resources import Requirement, get_distribution
from pkg_resources import resource_filename
from tempfile import gettempdir

# Mako
from mako import exceptions
from mako.lookup import TemplateLookup
# WebOb
from webob import Request, Response


class WSGIApplication(object):
    """Abstract Base Class for Archives Hub WSGI applications.

    Sub-classes must define the special __call__ method to make their
    instances of this class callable. This method should always call
    start_response, and return an iterable of string objects (list or
    generator).

    NOTE: any method that does not return an iterable suitable for returning
    to the server, should be indicated as internal using a leading
    underscore, e.g. _fetch_record
    """

    def __init__(self, config):
        self.config = config
        # Set up Mako templating
        template_dir = resource_filename(
            Requirement.parse('archiveshub'),
            'www/ead/tmpl'
        )
        mod_dir = os.path.join(gettempdir(),
                               'mako_modules',
                               'archiveshub',
                               'apps',
                               'ead'
                               )

        self.templateLookup = TemplateLookup(
            directories=[template_dir],
            output_encoding='utf-8',
            input_encoding='utf-8',
            module_directory=mod_dir,
            strict_undefined=False
        )
        self.defaultContext = {
            'version': get_distribution("archiveshub").version,
            'config': config
        }

    def _setUp(self, environ):
        # Prepare application to handle a new request
        # Wrap environ in a Request object
        req = self.request = Request(environ, charset='utf8')
        # Create a Response object with defaults for status, encoding etc.
        # Methods should over-ride these defaults as necessary
        self.response = Response()

    def _render_template(self, template_name, **kwargs):
        try:
            template = self.templateLookup.get_template(template_name)
            d = self.defaultContext.copy()
            d.update(kwargs)
            return template.render(**d)
        except:
            return exceptions.html_error_template().render()

