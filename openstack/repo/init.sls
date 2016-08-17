{% from "virl.jinja" import virl with context %}

include:
  {% if not virl.mitaka %}
  - openstack.repo.kilo
  {% endif %}
