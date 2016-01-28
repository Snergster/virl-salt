{% set ram_overcommit = salt['pillar.get']('virl:ram_overcommit', salt['grains.get']('ram_overcommit', '2')) %}
{% set cpu_overcommit = salt['pillar.get']('virl:cpu_overcommit', salt['grains.get']('cpu_overcommit', '3')) %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

set_values:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host ram_overcommit {{ ram_overcommit }}
      - crudini --set /etc/virl/common.cfg host cpu_overcommit {{ cpu_overcommit }}


