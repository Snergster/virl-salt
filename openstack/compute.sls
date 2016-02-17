
include:
  - openstack.repo.kilo
  - common.ifb
  - openstack.nova.compute
  - openstack.neutron.compute
  - openstack.setup
  - openstack.restart
  - openstack.compute-key

salt minion running:
  service.running:
    - name: salt-minion
    - enable: true
