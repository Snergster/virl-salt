{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false )) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false )) %}

all-restart:
  cmd.run:
    - name: |
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-compute restart
        service nova-novncproxy restart
        service neutron-server restart
        service neutron-dhcp-agent restart
        service neutron-l3-agent restart
        service neutron-metadata-agent restart
        service neutron-plugin-linuxbridge-agent restart
        service keystone restart
        service glance-api restart
        service glance-registry restart
        {% if heat == true %}
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart
        {% endif %}
