{% from "virl.jinja" import virl with context %}

include:
  - virl.routervms.virl-core-sync

{% if virl.lxc_server and virl.lxc_server_pref %}

lxc_server:
  virl_core.lxc_image_present:
  - subtype: lxc
  - version: ubuntu-ci
  {% if virl.mitaka %}
  - release: 16.04.0
  {% else %}
  - release: 14.04.2
  {% endif %}

  {% if not virl.cml %}
  remove dead tar:
    cmd.run:
      - order: last
      - names:
        - 'rm -f /var/local/virl/lxc/images/*lxc-ubuntu-ci.tar'
  {% endif %}
{% else %}

lxc_server gone:
  virl_core.lxc_image_absent:
  - subtype: lxc
  - version: ubuntu-ci

{% endif %}
