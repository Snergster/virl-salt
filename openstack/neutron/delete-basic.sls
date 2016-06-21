{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

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
