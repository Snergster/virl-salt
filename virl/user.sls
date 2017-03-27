{% set user = salt['environ.get']('virluser') %}
{% set pass = salt['environ.get']('virlpass') %}
{% set vcpu = salt['environ.get']('virlvcpu', 15 ) %}
{% set instances = salt['environ.get']('virlinstances', 15 ) %}
{% set expire = salt['environ.get']('virlexpire', 4 ) %}

create guest account:
  module.run:
    - name: virl_core.project_present
    - m_name: {{ user }}
    - description: {{ user }} project
    - quota_vcpus: {{ vcpu }}
    - quota_instances: {{ instances }}
    - expire: {{ expire }}
    - require:
      - cmd: virl-std start
      - cmd: virl-uwm start


fix guest password:
  module.run:
    - name: virl_core.user_present
    - m_name: {{ user }}
    - password: {{ pass }}
    - project: {{ user }}
    - role: _member_
    - require:
      - module: create guest account

virl-std start:
  cmd.run:
    - name: service virl-std start

virl-uwm start:
  cmd.run:
    - name: service virl-uwm start
