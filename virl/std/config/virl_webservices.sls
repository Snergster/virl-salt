{% set stdport = salt['pillar.get']('virl:virl_webservices', salt['grains.get']('virl_webservices', '19399')) %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
