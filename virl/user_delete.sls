
{% for username, user in pillar.get('virlusers', {}).items() %}
{{username}} user creator:
  module.run:
    - name: virl_core.project_absent
    - m_name: {{username}}
    - clear_openstack: True

{% endfor %}