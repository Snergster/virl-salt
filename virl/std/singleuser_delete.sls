{% for project in salt['virl_core.project_list']() %}
{% if project['name'] != 'uwmadmin' %}
singleuser_delete_{{ project['name'] }}:
  module.run:
    - name: virl_core.project_absent
    - m_name: {{ project['name'] }}
    - clear_openstack: True
{% endif %}
{% endfor %}
