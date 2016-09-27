{% from "virl.jinja" import virl with context %}


{% if virl.guestaccount %}

  {% if 'xenial' in salt['grains.get']('oscodename') %}

include:
  - common.salt-minion.sync-and-restart

  {% endif %}

create guest account:
  module.run:
    - name: virl_core.project_present
    - m_name: guest
    - quota_instances: 200
    - description: guest project
    - require:
      - cmd: virl-std start
      - cmd: virl-uwm start


fix guest password:
  module.run:
    - name: virl_core.user_present
    - m_name: guest
    - password: {{ virl.guestpassword }}
    - project: guest
    - role: admin
    - require:
      - module: create guest account
{% else %}
delete guest account:
  module.run:
    - name: virl_core.project_absent
    - m_name: guest
    - clear_openstack: True
{% endif %}

virl-std start:
  cmd.run:
    - name: service virl-std start

virl-uwm start:
  cmd.run:
    - name: service virl-uwm start
