{% set iol2 = salt['pillar.get']('lxcimages:iol2', True) %}
{% set iol2pref = salt['pillar.get']('virl:iol2', salt['grains.get']('iol2', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if iol2 and iol2pref %}

iol2:
  virl_core.lxc_image_present:
  - subtype: IOL2
  - release: ms.dec23_2015_high_iron

{% else %}

iol2 gone:
  virl_core.lxc_image_absent:
  - subtype: IOL2

{% endif %}
