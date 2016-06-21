{% from "virl.jinja" import virl with context %}

include:
  - .prereq
  - .clients
  - common.ifb
{% if not virl.cml %}
  - virl.std.tap-counter
{% endif %}
  - .install
