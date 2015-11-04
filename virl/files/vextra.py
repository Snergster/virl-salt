#!/usr/bin/python
#__author__ = 'ejk'


"""virl extra builder

Usage:
  vextra [hard]
  vextra [salt]

Arguments:
  hard                  Removes extra.conf file before running
  salt                  Rebuild grains data only


Options:
  --version             shows program's version number and exit
  -h, --help            show this help message and exit
"""


import subprocess
import ConfigParser
import salt.client
from docopt import docopt
from os import path

opts = salt.config.minion_config('/etc/salt/minion')
sopts = salt.config.minion_config('/etc/salt/minion')
opts['file_client'] = 'local'
opts['fileserver_backend'] = 'roots'
caller = salt.client.Caller(mopts=opts)

Config = ConfigParser.ConfigParser()

# virlconfig_file = '/etc/virl.ini'


def building_salt_extra(masterless,salt_master,salt_id,salt_domain):
    with open(("/tmp/extra"), "w") as extra:
        if not masterless:
            if len(salt_master.split(',')) >= 2:
                extra.write("""master: [{salt_master}]\n""".format(salt_master=salt_master))
                extra.write("""master_type: failover \n""")
                extra.write("""master_shuffle: True \n""")
                extra.write("""random_master: True \n""")
            else:
                extra.write("""master: {salt_master}\n""".format(salt_master=salt_master))

            extra.write("""verify_master_pubkey_sign: True \n""")
            extra.write("""auth_timeout: 15 \n""")
            extra.write("""master_alive_interval: 180 \n""")
            extra.write("""state_output: mixed \n""")
        else:
            if path.exists('/usr/local/lib/python2.7/dist-packages/pygit2'):
                extra.write("""gitfs_provider: pygit2\n""")
                extra.write("""file_client: local

fileserver_backend:
  - git
  - roots

state_output: mixed 

gitfs_remotes:
  - https://github.com/Snergster/virl-salt.git\n""")
            elif path.exists('/usr/local/lib/python2.7/dist-packages/dulwich'):
                extra.write("""gitfs_provider: dulwich\n""")
                extra.write("""file_client: local

fileserver_backend:
  - git
  - roots

state_output: mixed 

gitfs_remotes:
  - https://github.com/Snergster/virl-salt.git\n""")
        extra.write("""log_level: quiet \n""")
        extra.write("""id: '{salt_id}'\n""".format(salt_id=salt_id))
        extra.write("""append_domain: {salt_domain}\n""".format(salt_domain=salt_domain))
    subprocess.call(['sudo', 'mv', '-f', ('/tmp/extra'), '/etc/salt/minion.d/extra.conf'])

def building_salt_openstack(ospassword,ks_token,mypass,admin_id):
    with open(("/tmp/openstack"), "w") as openstack:
        openstack.write("""keystone.user: admin
keystone.password: {ospassword}
keystone.tenant: admin
keystone.tenant_id: {admin_id}
keystone.auth_url: 'http://127.0.0.1:5000/v2.0/'
keystone.token: {kstoken}
keystone.region_name: 'RegionOne'

mysql.user: root
mysql.pass: {mypass}

virl:
  keystone.user: admin
  keystone.password: {ospassword}
  keystone.tenant: admin
  keystone.tenant_id: {admin_id}
  keystone.auth_url: 'http://127.0.0.1:5000/v2.0/'
  keystone.region_name: 'RegionOne'\n""".format(ospassword=ospassword, kstoken=ks_token, mypass=mypass, admin_id=admin_id))
    subprocess.call(['sudo', 'mv', '-f', ('/tmp/openstack'), '/etc/salt/minion.d/openstack.conf'])


if __name__ == "__main__":

    varg = docopt(__doc__, version='vextra .1')

    if path.exists('/etc/virl.ini'):
        Config.read('/etc/virl.ini')
        vgrains = {}
        for name, value in Config.items('DEFAULT'):
            if name == 'domain': vgrains['domain_name'] = value
            if value.lower() == 'true':
                vgrains[name] = True
            elif value.lower() == 'false':
                vgrains[name] = False
            else:
                vgrains[name] = value
        caller.sminion.functions['grains.setvals'](vgrains)
    else:
        print "No config exists at /etc/virl.ini."
        exit(1)
    if varg['hard']:
        subprocess.call(['sudo', 'rm', '-f', '/etc/salt/minion.d/extra.conf'])
    if not varg['salt']:
        masterless = caller.sminion.functions['grains.get']('salt_masterless')
        if masterless == True:
            salt_id = caller.sminion.functions['grains.get']('salt_id')
            salt_domain = caller.sminion.functions['grains.get']('salt_domain')
            salt_master = ''
            building_salt_extra(masterless,salt_master,salt_id,salt_domain)
            ospassword = caller.sminion.functions['grains.get']('password')
            mypass = caller.sminion.functions['grains.get']('mysql_password')
            ks_token = caller.sminion.functions['grains.get']('keystone_service_token')
            admin_id = caller.sminion.functions['grains.get']('admin_id', ' ')
        else:
            scaller = salt.client.Caller(mopts=sopts)
            try:
                salt_master = scaller.sminion.functions['pillar.get']('virl:salt_master')
                if not salt_master:
                    salt_master = caller.sminion.functions['grains.get']('salt_master')
                salt_id = scaller.sminion.functions['pillar.get']('virl:salt_id')
                if not salt_id:
                    salt_id = caller.sminion.functions['grains.get']('salt_id')
                salt_domain = scaller.sminion.functions['pillar.get']('virl:salt_domain')
                if not salt_domain:
                    salt_domain = caller.sminion.functions['grains.get']('salt_domain')
                ospassword = scaller.sminion.functions['pillar.get']('virl:password')
                if not ospassword:
                    ospassword = caller.sminion.functions['grains.get']('password')
                mypass = scaller.sminion.functions['pillar.get']('virl:mysql_password')
                if not mypass:
                    mypass = caller.sminion.functions['grains.get']('mysql_password')
                ks_token = scaller.sminion.functions['pillar.get']('virl:keystone_service_token')
                if not ks_token:
                    ks_token = caller.sminion.functions['grains.get']('keystone_service_token')
                admin_id = caller.sminion.functions['grains.get']('admin_id', ' ')
                building_salt_extra(masterless,salt_master,salt_id,salt_domain)
            except AttributeError:
                salt_master = caller.sminion.functions['grains.get']('salt_master')
                salt_id = caller.sminion.functions['grains.get']('salt_id')
                salt_domain = caller.sminion.functions['grains.get']('salt_domain')
                salt_master = caller.sminion.functions['grains.get']('salt_master')
                ospassword = caller.sminion.functions['grains.get']('password')
                mypass = caller.sminion.functions['grains.get']('mysql_password')
                ks_token = caller.sminion.functions['grains.get']('keystone_service_token')
                admin_id = caller.sminion.functions['grains.get']('admin_id', ' ')
                building_salt_extra(masterless,salt_master,salt_id,salt_domain)

        building_salt_openstack(ospassword,ks_token,mypass,admin_id)
    else:
        print 'Updated grain data only'