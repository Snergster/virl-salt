{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false )) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false )) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}



all-restart:
  cmd.run:
    - name: |
        su -s /bin/sh -c "glance-manage db_sync" glance
        su -s /bin/sh -c "nova-manage db sync" nova
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-compute restart
        service nova-novncproxy restart
        service nova-serialproxy restart
        service neutron-server restart
        service neutron-dhcp-agent restart
        service neutron-l3-agent restart
        service neutron-metadata-agent restart
        service neutron-plugin-linuxbridge-agent restart
        service glance-api restart
        service glance-registry restart
        {% if not kilo %}
        service keystone restart
        {% endif %}


{% if cinder %}
cinder-restart all:
  cmd.run:
    - name: |
        service cinder-api restart
        service cinder-scheduler restart
        service cinder-volume restart
{% endif %}

{% if heat == true %}
heat-restart all:
  cmd.run:
    - name: |
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart
{% endif %}
