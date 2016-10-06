{% from "virl.jinja" import virl with context %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

std uwm port replace:
  file.replace:
      - name: /var/www/html/index.html
      - pattern: :\d{2,}"
      - repl: :{{ virl.uwmport }}"
      - unless: grep {{ virl.uwmport }} /var/www/html/index.html

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ virl.uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ virl.uwmport }}

{% if virl.mitaka %}


user management auth url:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_openstack_auth_url http://localhost:5000/{{virl.keystone_auth_version}}

{% endif %}


