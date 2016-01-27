{% set host_simulation_port_min_tcp = salt['pillar.get']('virl:host_simulation_port_min_tcp', salt['grains.get']('host_simulation_port_min_tcp', '10000')) %}
{% set host_simulation_port_max_tcp = salt['pillar.get']('virl:host_simulation_port_max_tcp', salt['grains.get']('host_simulation_port_max_tcp', '17000')) %}

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_min_tcp {{ host_simulation_port_min_tcp }}
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_max_tcp {{ host_simulation_port_max_tcp }}

include:
  - .std_restart
  - .uwm_restart

