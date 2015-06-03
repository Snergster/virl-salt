
{% for username, user in pillar.get('virlusers', {}).items() %}
{{username}} user creator:
  module.run:
    - name: virl_core.project_present
    - m_name: {{username}}
    - description: {{user['description']}}
    - quota_vcpus: {{user['vcpus']}}
    - quota_instances: {{user['instances']}}
    - user_password: {{user['password']}}

fix {{username}} password:
  module.run:
    - name: virl_core.user_present
    - m_name: {{username}}
    - password: {{user['password']}}
    - project: {{username}}
    - role: _member_
{% endfor %}