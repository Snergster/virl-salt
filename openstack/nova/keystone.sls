{% set admin_tenid = salt.keystone.tenant_get(name='admin') %}

nova_admin_tenant_id insert:
  file.replace:
    - name: /etc/salt/minion.d/openstack.conf
    - repl: 'keystone.tenant_id: {{ admin_tenid.admin.id }}'
    - pattern: 'keystone\.tenant_id\:.*'
