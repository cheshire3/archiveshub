"""Abstract Base Class for Archives Hub WSGI Applications."""

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

    def _setUp(self, environ):
        # Prepare application to handle a new request
        # Wrap environ in a Request object
        req = self.request = Request(environ, charset='utf8')
        # Create a Response object with defaults for status, encoding etc.
        # Methods should over-ride these defaults as necessary
        self.response = Response()
