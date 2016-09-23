{% from "virl.jinja" import virl with context %}

include:
  - virl.network.system
  - virl.network.br4
  - virl.network.br1
  - virl.network.br3
{% if virl.l2_port2_enabled %}
  - virl.network.br2
{% endif %}

