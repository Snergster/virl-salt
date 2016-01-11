{% set guestaccount = salt['pillar.get']('virl:guest_account', salt['grains.get']('guest_account', True)) %}
{% set guestpassword = salt['pillar.get']('virl:guest_password', salt['grains.get']('guest_password', 'guest')) %}
{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}
{% if guestaccount == True %}

create guest account:
  module.run:
    - name: virl_core.project_present
    - m_name: guest
    - description: guest project
    - require:
      - cmd: virl-std start
      - cmd: virl-uwm start


fix guest password:
  module.run:
    - name: virl_core.user_present
    - m_name: guest
    - password: {{ guestpassword }}
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
