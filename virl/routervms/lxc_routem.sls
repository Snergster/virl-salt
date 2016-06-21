{% set lxc_routem = salt['pillar.get']('lxcimages:lxc_routem', True) %}
{% set lxc_routem_pref = salt['pillar.get']('virl:lxc_routem', salt['grains.get']('lxc_routem', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if lxc_routem and lxc_routem_pref %}

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
