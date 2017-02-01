{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.lxc_routem and virl.lxc_routempref %}

lxc_routem:
  virl_core.lxc_image_present:
  - subtype: lxc-routem
  - version: standard
  - release: 2.1(8)

{% else %}

lxc_routem gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-routem
  - version: standard

{% endif %}
