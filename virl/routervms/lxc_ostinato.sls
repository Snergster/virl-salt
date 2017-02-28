{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

# get rid of any old version
lxc_ostinato_gone:
  virl_core.lxc_image_absent:
  - subtype: lxc-ostinato
  - version: standard

{% if virl.lxc_ostinato and virl.lxc_ostinatopref %}

# original virl-core for 1.2.* needs to use older name
{% set subtype_reported = 'lxc-ostinato' + ('' if '0.10.28' in salt['pillar.get']('files:virl', '') else '-drone') %}

lxc_ostinato:
  virl_core.lxc_image_present:
  - subtype: {{ subtype_reported }}
  - version: standard
  - release: 0.8

{% else %}

lxc_ostinato gone:
  virl_core.lxc_image_absent:
  - subtype: {{ subtype_reported }}
  - version: standard

{% endif %}
