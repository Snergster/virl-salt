{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set keystone_auth_version = salt['pillar.get']('virl:keystone_auth_version', salt['grains.get']('keystone_auth_version', 'v2.0')) %}
{% set controller_ip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% from "virl.jinja" import virl with context %}

{% set log_str = "--os-tenant-name admin --os-username admin --os-password %s --os-auth-url=http://%s%s/%s" % (ospassword, controller_ip, ':5000', keystone_auth_version) %}
{% set router_list_cmd = "neutron %s router-list --format csv --quote none --column id" % log_str %}

# delete interfaces
{% set routers = salt['cmd.run'](router_list_cmd) %}
{% for router in routers.split('\n')[1:] %}
  {% set list_int_cmd = "neutron %s router-port-list --format csv --quote none --column id %s" % (log_str, router) %}
  {% set interfaces = salt['cmd.run'](list_int_cmd) %}
  {% for int in interfaces.split('\n')[1:] %}
    {% set router_int_delete_cmd = "neutron %s router-interface-delete %s port=%s" % (log_str, router, int) %}
    device-interface-delete-{{ router }}-{{ int }}:
      cmd.run:
       - name: {{ router_int_delete_cmd }}
  {% endfor %}
{% endfor %}

# update ports device owner
update device owner:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} port-update --device-id None --device-owner None $1

# delete ports
delete ports:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} port-delete $1

# delete floating ips
delete floating ips:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} floatingip-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} floatingip-delete $1

clear ext-net router-gateway:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} router-list -c id -f csv | grep -o '[a-fA-F0-9-]\{36\}' | xargs -n 1 neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} router-gateway-clear
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} subnet-show ext-net

{% for each in ['flat','flat1','ext-net'] %}
delete {{ each }}:
#  module.run:
#    - name: neutron.delete_subnet
#    - subnet: {{ each }}
#    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} subnet-show {{ each }}
# this seems to work flawlessly, above fails mysteriously
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} subnet-delete {{ each }}
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }} subnet-show {{ each }}
{% endfor %}
