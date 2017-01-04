
include:
  - .csr1000v
  - .iosv
  - .iosxrv
  - .lxc_iperf
  - .lxc_routem
  - .lxc_ostinato
  - .vpagent
  - .nxosv
  - .iosvl2
  - .asav
  - .lxc_server
  - .nxosv9k
  - .iosxrv9000
{% if 'xenial' in salt['grains.get']('oscodename') %}
  - .xenial_server
{% else %}
  - .server
{% endif %}
{% if 'cisco.com' in salt['grains.get']('id') %}
  - .iol
  - .iol_l2
{% endif %}
