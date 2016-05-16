{% set iol2 = salt['pillar.get']('lxcimages:iol-l2', False) %}
{% set iol2pref = salt['pillar.get']('virl:iol-l2', salt['grains.get']('iol-l2', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if iol2 and iol2pref %}

iol2:
  virl_core.lxc_image_present:
  - subtype: IOL-L2
  - release: high_iron_010416

{% else %}

iol2 gone:
  virl_core.lxc_image_absent:
  - subtype: IOL-L2

{% endif %}
