{% set lxc_iperf = salt['pillar.get']('lxcimages:lxc_iperf', True) %}
{% set lxc_iperf_pref = salt['pillar.get']('virl:lxc_iperf', salt['grains.get']('lxc_iperf', True)) %}

{% if lxc_iperf and lxc_iperf_pref %}

lxc_iperf:
  virl_core.lxc_image_present:
  - subtype: lxc-iperf
  - version: standard
  - release: 2.0.2

{% else %}

lxc_iperf gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-iperf
  - version: standard

{% endif %}
