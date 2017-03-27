{% set service_tenid = salt['keystone.tenant_get'](name='service') %}

l3-gateway set:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'gateway_external_network_id'
    - value: ' '

nova_admin_tenant_id insert in changes:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_tenant_id'
    - value: {{ service_tenid.service.id }}

service_tenant_id in grains:
    grains.present:
        - name: service_id
        - value: {{ service_tenid.service.id }}
