{% set ip = salt['cmd.run']("/usr/local/bin/getintip") %}


controller int in virl.ini:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'local_ip'
    - value: {{ip}}
