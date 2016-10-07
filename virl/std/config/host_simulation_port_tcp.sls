{% set host_simulation_port_min_tcp = salt['pillar.get']('virl:host_simulation_port_min_tcp', salt['grains.get']('host_simulation_port_min_tcp', '10000')) %}
{% set host_simulation_port_max_tcp = salt['pillar.get']('virl:host_simulation_port_max_tcp', salt['grains.get']('host_simulation_port_max_tcp', '17000')) %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_min_tcp {{ host_simulation_port_min_tcp }}
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_max_tcp {{ host_simulation_port_max_tcp }}
      - crudini --set /etc/virl/virl-core.ini limits host_simulation_port_min_tcp {{ host_simulation_port_min_tcp }}
      - crudini --set /etc/virl/virl-core.ini limits host_simulation_port_max_tcp {{ host_simulation_port_max_tcp }}


