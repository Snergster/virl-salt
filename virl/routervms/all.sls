
include:
  - .csr1000v
  - .iosv
  - .iosxrv
  - .server
  - .lxc_iperf
  - .lxc_routem
  - .lxc_ostinato
  - .vpagent
  - .nxosv
  - .iosvl2
  - .asav
  - .lxc_server
{% if 'cisco.com' in salt['grains.get']('id') %}
  - .iol
  - .iol_l2
{% endif %}
