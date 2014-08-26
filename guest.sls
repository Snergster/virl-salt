{% set guestaccount = salt['grains.get']('guest account', 'True') %}
{% set uwmpass = salt['grains.get']('uwmadmin password', 'password') %}

{% if guestaccount == True %}

create guest account:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_client -u uwmadmin -p {{ uwmpass }} project-create --name guest
    - require:
      - service: virl-std
      - service: virl-uwm

fix guest password:
  cmd.wait:
    - name: /usr/local/bin/virl_uwm_server set-password -u guest -p {{ uwmpass }} -P guest
    - watch:
      - cmd: create guest account
{% else %}
delete guest account:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_client -u uwmadmin -p {{ uwmpass }} project-delete --name guest
{% endif %}
