{% from "virl.jinja" import virl with context %}

include:
  {% if virl.mitaka %}
  - openstack.repo.mitaka
  {% else %}
  - openstack.repo.kilo
  {% endif %}
