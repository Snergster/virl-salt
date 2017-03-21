{% from "virl.jinja" import virl with context %}

{% if not virl.controller %}
{% if virl.mitaka %}

{% for service in 'nova-compute', 'neutron-linuxbridge-agent' %}
enable {{ service }}:
  service.enabled:
    - name: {{ service }}
start {{ service }}:
  service.running:
    - name: {{ service }}
{% endfor %}

{% for service in 'nova-api',
                  'nova-consoleauth',
		  'nova-scheduler',
		  'nova-cert',
		  'nova-conductor',
		  'nova-novncproxy',
		  'nova-serialproxy',
		  'neutron-dhcp-agent',
		  'neutron-l3-agent',
		  'neutron-metadata-agent',
		  'neutron-server' %}
disable {{ service }}:
  service.disabled:
    - name: {{ service }}
stop {{ service }}:
  service.dead:
    - name: {{ service }}
{% endfor %}

{% endif %}
{% endif %}
