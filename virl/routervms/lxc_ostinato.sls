{% set lxc_ostinato = salt['pillar.get']('lxcimages:lxc_ostinato', True) %}
{% set lxc_ostinato_pref = salt['pillar.get']('virl:lxc_ostinato', salt['grains.get']('lxc_ostinato', True)) %}

include:
  - virl.routervms.virl-core-sync

{% if lxc_ostinato and lxc_ostinato_pref %}

lxc_ostinato:
  virl_core.lxc_image_present:
  - subtype: lxc-ostinato
  - version: standard
  - release: 0.8-1

{% else %}

lxc_ostinato gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-ostinato
  - version: standard

{% endif %}
