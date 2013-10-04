"""Cheshire3 for Archives Setup Exceptions."""


class SetupException(Exception):
    """Base Class for Exceptions raised during setup."""

    def __init__(self, text="None"):
        self.message = text

    def __str__(self):
        return str(self.__class__) + ": " + self.message

    def __repr__(self):
        return str(self.__class__) + ": " + self.message


class DevelopException(SetupException):
    """An Exception raised during ``python setup.py develop``."""
    pass


class InstallException(SetupException):
    """An Exception raised during ``python setup.py install``."""
    pass


class UninstallException(SetupException):
    """An Exception raised during ``python setup.py uninstall``."""
    pass
