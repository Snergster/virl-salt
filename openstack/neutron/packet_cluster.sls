{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True )) %}

{% if controller %}

packet tunnel specific localip:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'vxlan'
    - parameter: 'local_ip'
    - value: '{{ salt['pillar.get']('virl:neutron_local_ip', salt['grains.get']('neutron_local_ip', '172.16.9.10')) }}'

{% else %}

packet tunnel specific localip:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'vxlan'
    - parameter: 'local_ip'
    - value: '{{ salt['pillar.get']('virl:neutron_local_ip', '172.16.9.5') }}'

{% endif %}