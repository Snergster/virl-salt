{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.iol2pref %}

iol-l2:
  virl_core.lxc_image_present:
  - subtype: IOL-L2
  - release: {{ salt['pillar.get']('version:iol_l2')}}

{% else %}

iol-l2 gone:
  virl_core.lxc_image_absent:
  - subtype: IOL-L2

{% endif %}
