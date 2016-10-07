{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

std uwm port replace:
  file.replace:
      - name: /var/www/html/index.html
      - pattern: :\d{2,}"
      - repl: :{{ uwmport }}"
      - unless: grep {{ uwmport }} /var/www/html/index.html

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}
      - crudini --set /etc/virl/virl-core.ini env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl-core.ini env virl_uwm_url http://localhost:{{ uwmport }}


