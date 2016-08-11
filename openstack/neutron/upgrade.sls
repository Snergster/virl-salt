{% from "virl.jinja" import virl with context %}

neutron linuxbridge unhold:
  module.run:
    - name: pkg.unhold
    - m_name: neutron-plugin-linuxbridge-agent
    - prereq:
      - pkg: neutron pull to latest

neutron pull to latest:
  pkg.latest:
    - pkgs:
      - neutron-common
      - neutron-dhcp-agent
      - neutron-l3-agent
      - neutron-metadata-agent
      - neutron-plugin-linuxbridge-agent
{% if not virl.mitaka %}
      - neutron-plugin-linuxbridge
{% endif %}
      - neutron-plugin-ml2
      - neutron-server
      - python-neutron
  apt.held:
    - name: neutron-plugin-linuxbridge-agent

