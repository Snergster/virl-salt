{% set guestaccount = salt['grains.get']('guest_account', 'True') %}
{% set uwmpass = salt['grains.get']('uwmadmin_password', 'password') %}

{% if guestaccount == True %}

create guest account:
  virl_core.project_present:
    - name: guest
    - description: guest project
    - require:
      - cmd: virl-std
      - cmd: virl-uwm


fix guest password:
  virl_core.user_present:
    - name: guest
    - password: guest
    - project: guest
    - role: _member_
    - require:
      - virl_core: create guest account
{% else %}
delete guest account:
  virl_core.project_absent:
    - name: guest
    - clear_openstack: True
{% endif %}

virl-std:
  cmd.run:
    - name: service virl-std start

virl-uwm:
  cmd.run:
    - name: service virl-uwm start


