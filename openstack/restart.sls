{% from "virl.jinja" import virl with context %}

{% if virl.controller %}

all-restart:
  cmd.run:
    - name: |
        su -s /bin/sh -c "glance-manage db_sync" glance
        su -s /bin/sh -c "nova-manage db sync" nova
{% if virl.mitaka %}
        su -s /bin/sh -c "nova-manage api_db sync" nova
{% endif %}
        service apache2 restart
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


  {% if virl.cinder %}
cinder-restart all:
  cmd.run:
    - name: |
        service cinder-api restart
        service cinder-scheduler restart
        service cinder-volume restart
  {% endif %}

  {% if virl.heat %}
heat-restart all:
  cmd.run:
    - name: |
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart
  {% endif %}

{% else %}

all-restart:
  cmd.run:
    - name: |
        service nova-compute restart
        service neutron-plugin-linuxbridge-agent restart

{% endif %}