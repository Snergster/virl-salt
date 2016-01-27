{% set ram_overcommit = salt['pillar.get']('virl:ram_overcommit', salt['grains.get']('ram_overcommit', '2')) %}
{% set cpu_overcommit = salt['pillar.get']('virl:cpu_overcommit', salt['grains.get']('cpu_overcommit', '3')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

set_values:
  cmd.run:
    - names:
     {% if kilo %}
      - crudini --set /etc/virl/common.cfg host ram_overcommit {{ ram_overcommit }}
      - crudini --set /etc/virl/common.cfg host cpu_overcommit {{ cpu_overcommit }}
     {% endif %}

include:
  - .std_restart
  - .uwm_restart

