#!/usr/bin/python
#__author__ = 'ejk'

import ConfigParser
import salt.client
from os import path

caller = salt.client.Caller()
Config = ConfigParser.ConfigParser()

virlconfig_file = '/etc/virl.ini'
if path.exists(virlconfig_file):
    Config.read('/etc/virl.ini')
else:
    print "No config exists at /etc/virl.ini."
    exit(1)

if __name__ == "__main__":
    vgrains = {}
    for name, value in Config.items('DEFAULT'): vgrains[name] = value
    caller.sminion.functions['grains.setvals'](vgrains)
