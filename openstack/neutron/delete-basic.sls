{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

{% set log_str = "--os-tenant-name admin --os-username admin --os-password %s --os-auth-url=http://%s%s/v2.0" % (ospassword, controllerip, ':5000') %}
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
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 port-update --device-id None --device-owner None $1

# delete ports
delete ports:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 port-delete $1

# delete floating ips
delete floating ips:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 floatingip-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 floatingip-delete $1

clear ext-net router-gateway:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 router-list -c id -f csv | grep -o '[a-fA-F0-9-]\{36\}' | xargs -n 1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 router-gateway-clear
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 subnet-show ext-net

{% for each in ['flat','flat1','ext-net'] %}
delete {{ each }}:
#  module.run:
#    - name: neutron.delete_subnet
#    - subnet: {{ each }}
#    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 subnet-show {{ each }}
# this seems to work flawlessly, above fails mysteriously
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 subnet-delete {{ each }}
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 subnet-show {{ each }}
{% endfor %}
