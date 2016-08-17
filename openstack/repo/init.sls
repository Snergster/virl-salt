{% from "virl.jinja" import virl with context %}

  {% if not virl.mitaka %}
include:
  - openstack.repo.kilo
  {% endif %}
