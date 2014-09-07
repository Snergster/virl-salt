{% set guestaccount = salt['grains.get']('guest account', 'True') %}
{% set uwmpass = salt['grains.get']('uwmadmin password', 'password') %}

{% if guestaccount == True %}

create guest account:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_client -u uwmadmin -p {{ uwmpass }} project-create --name guest
    - require:
      - cmd: virl-std
      - cmd: virl-uwm


fix guest password:
  cmd.run:
    - name: sleep 4 && /usr/local/bin/virl_uwm_server set-password -u guest -p guest -P guest
{% else %}
delete guest account:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_client -u uwmadmin -p {{ uwmpass }} project-delete --name guest
{% endif %}

virl-std:
  cmd.run:
    - name: service virl-std start

virl-uwm:
  cmd.run:
    - name: service virl-uwm start


