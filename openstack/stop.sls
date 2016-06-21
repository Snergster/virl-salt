{% set heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', false )) %}
{% set cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', false )) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}

all-stop:
  cmd.run:
    - name: |
        service nova-cert stop
        service nova-api stop
        service nova-consoleauth stop
        service nova-scheduler stop
        service nova-conductor stop
        service nova-compute stop
        service nova-novncproxy stop
        service nova-serialproxy stop
        service neutron-server stop
        service neutron-dhcp-agent stop
        service neutron-l3-agent stop
        service neutron-metadata-agent stop
        service neutron-plugin-linuxbridge-agent stop
        service glance-api stop
        service glance-registry stop
        {% if heat == true %}
        service heat-api stop
        service heat-api-cfn stop
        service heat-engine stop
        {% endif %}
        service rabbitmq-server stop
        {% if cinder == true %}
        service cinder-api stop
        service cinder-scheduler stop
        service cinder-volume stop
        {% endif %}
