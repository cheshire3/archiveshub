#!/usr/bin/env sh
createdb cheshire3
python -m cheshire3.test.testAll && python setup.py test
exit $?