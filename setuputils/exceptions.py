"""Cheshire3 for Archives Setup Exceptions."""


class SetupException(Exception):
    
    def __init__(self, text="None"):
        self.message = text

    def __str__(self):
        return str(self.__class__) + ": " + self.message

    def __repr__(self):
        return str(self.__class__) + ": " + self.message

    
class DevelopException(SetupException):
    pass


class InstallException(SetupException):
    pass


class UninstallException(SetupException):
    pass
