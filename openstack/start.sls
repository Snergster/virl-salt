{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false )) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false )) %}

all-start:
  cmd.run:
    - name: |
        service nova-cert start
        service nova-api start
        service nova-consoleauth start
        service nova-scheduler start
        service nova-conductor start
        service nova-compute start
        service nova-novncproxy start
        service nova-serialproxy start
        service neutron-server start
        service neutron-dhcp-agent start
        service neutron-l3-agent start
        service neutron-metadata-agent start
        service neutron-plugin-linuxbridge-agent start
        service keystone start
        service glance-api start
        service glance-registry start
        {% if heat == true %}
        service heat-api start
        service heat-api-cfn start
        service heat-engine start
        {% endif %}
        service rabbitmq-server start
        {% if cinder == true %}
        service cinder-api restart
        service cinder-scheduler restart
        service cinder-volume restart
        {% endif %}
        
