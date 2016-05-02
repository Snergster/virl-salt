{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set iol = salt['pillar.get']('routervms:iol', False) %}
{% set iol2 = salt['pillar.get']('routervms:iol2', False) %}
{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosxrv = salt['pillar.get']('routervms:iosxrv', False ) %}
{% set iosxrv432 = salt['pillar.get']('routervms:iosxrv432', False ) %}
{% set nxosv = salt['pillar.get']('routervms:nxosv', False) %}
{% set csr1000v = salt['pillar.get']('routervms:csr1000v', False) %}
{% set vpagent = salt['pillar.get']('routervms:vpagent', False) %}
{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}
{% set lxc = salt['pillar.get']('routervms:lxc_server', True) %}
{% set lxciperf = salt['pillar.get']('routervms:lxc_iperf', True) %}
{% set lxcroutem = salt['pillar.get']('routervms:lxc_routem', True) %}
{% set lxcostinato = salt['pillar.get']('routervms:lxc_ostinato', True) %}

{% set iolpref = salt['pillar.get']('virl:iol', salt['grains.get']('iol', True)) %}
{% set iol2pref = salt['pillar.get']('virl:iol2', salt['grains.get']('iol2', True)) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set iosxrv432pref = salt['pillar.get']('virl:iosxrv432', salt['grains.get']('iosxrv432', True)) %}
{% set iosxrvpref = salt['pillar.get']('virl:iosxrv', salt['grains.get']('iosxrv', True)) %}
{% set csr1000vpref = salt['pillar.get']('virl:csr1000v', salt['grains.get']('csr1000v', True)) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}
{% set vpagentpref = salt['pillar.get']('virl:vpagent', salt['grains.get']('vpagent', True)) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}
{% set lxcpref = salt['pillar.get']('virl:lxc_server', salt['grains.get']('lxc_server', True)) %}
{% set lxciperfpref = salt['pillar.get']('virl:lxc_iperf', salt['grains.get']('lxc_iperf', True)) %}
{% set lxcroutempref = salt['pillar.get']('virl:lxc_routem', salt['grains.get']('lxc_routem', True)) %}
{% set lxcostinatopref = salt['pillar.get']('virl:lxc_ostinato', salt['grains.get']('lxc_ostinato', True)) %}

include:
  - .csr1000v
  - .iol
  - .iol2
  - .iosv
  - .iosxrv
  - .server
  - .lxc_server
  - .lxc_iperf
  - .lxc_routem
  - .lxc_ostinato
  - .vpagent
  - .nxosv
  - .iosvl2
  - .asav
  - .iosxrv52
