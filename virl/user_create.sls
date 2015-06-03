
{% for username, user in pillar.get('virlusers', {}).items() %}
{% set expires = user['expires'] %}
{{username}} user creator:
  module.run:
    - name: virl_core.project_present
    - mname: {{username}}
    - description={{user['description']}}
    - quota_vcpus={{user['vcpus']}}
    {% if expires %}
    - expires={{expires}}
    {% endif %}
    - quota_instances={{user['instances']}}
    - user_password={{user['password']}}
{% endfor %}