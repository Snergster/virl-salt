{% set lxc_server = salt['pillar.get']('lxcimages:lxc_server', True) %}
{% set lxc_server_pref = salt['pillar.get']('virl:lxc_server', salt['grains.get']('lxc_server', True)) %}
{% set cml = salt['grains.get']('cml', False) %}

include:
  - virl.routervms.virl-core-sync

{% if lxc_server and lxc_server_pref %}

lxc_server:
  virl_core.lxc_image_present:
  - subtype: lxc
  - version: ubuntu-ci
  - release: 14.04.2

  {% if not cml %}
remove dead tar:
  cmd.run:
    - order: last
    - names:
      - 'rm /var/local/virl/lxc/images/*lxc-ubuntu-ci.tar'
  {% endif %}
{% else %}

lxc_server gone:
  virl_core.lxc_image_absent:
  - subtype: lxc
  - version: ubuntu-ci

{% endif %}
