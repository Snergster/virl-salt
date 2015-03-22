{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}

{% for each in ['flat','flat1','ext-net'] %}
delete {{ each }}:
  module.run:
    - name: neutron.delete_subnet
    - subnet: {{ each }}
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/v2.0 subnet-show {{ each }}
{% endfor %}
