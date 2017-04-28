{% from "virl.jinja" import virl with context %}

{% if not virl.controller %}
{% if virl.mitaka %}

{% for service in 'nova-compute', 'neutron-linuxbridge-agent' %}
disable {{ service }}:
  service.disabled:
    - name: {{ service }}
stop {{ service }}:
  service.dead:
    - name: {{ service }}
{% endfor %}

{% endif %}
{% endif %}
