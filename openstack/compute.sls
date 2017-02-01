{% from "virl.jinja" import virl with context %}

redis-py:
  pip.installed:
    - name: redis>=2.10.5
    {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
    {% endif %}

include:
  - openstack.repo
  - virl.ntp
  - common.ifb
  - openstack.nova.compute
  - openstack.neutron.compute
  - openstack.setup
  - virl.std.tap-counter
  - openstack.restart
  - openstack.compute-key
  - common.salt-minion.running
  - common.bridge
