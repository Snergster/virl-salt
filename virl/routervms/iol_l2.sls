{% set iol2pref = salt['pillar.get']('virl:iol_l2', salt['grains.get']('iol_l2', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if iol2pref %}

iol-l2:
  virl_core.lxc_image_present:
  - subtype: IOL-L2
  - release: high_iron_010416

{% else %}

iol-l2 gone:
  virl_core.lxc_image_absent:
  - subtype: IOL-L2

{% endif %}
