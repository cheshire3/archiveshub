#!/usr/bin/env sh
pip install pytest nose mock
python ez_setup.py
pip install -r requirements.txt --find-links http://cheshire3.liv.ac.uk/download/latest/reqs/ --trusted-host cheshire3.liv.ac.uk --allow-unverified PyZ3950 --allow-unverified ZSI
python setup.py install
