{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.lxc_ostinato and virl.lxc_ostinatopref %}

lxc_ostinato_gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-ostinato
  - version: standard

lxc_ostinato:
  virl_core.lxc_image_present:
  - subtype: lxc-ostinato-drone
  - version: standard
  - release: 0.8

{% else %}

lxc_ostinato gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-ostinato-drone
  - version: standard

{% endif %}
