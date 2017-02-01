{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.lxc_iperf and virl.lxc_iperf_pref %}

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
