{% set mitaka = salt['pillar.get']('virl:mitaka', salt['grains.get']('mitaka', false)) %}

{% if mitaka %}
# required before vinstall otherwise fails on openstack db connects
include:
  - openstack.mysql.install

# workaround for non-working aggregate/fromrepo issues? https://github.com/saltstack/salt/issues/21876
qemu unhold:
 pkg.installed:
   - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common
   - hold: False
qemu purge:
 pkg.removed:
   - pkgs:
      - qemu-system-x86
      - qemu-kvm
      - qemu-system-common

disable upgrades:
 pkg.removed:
   - pkgs:
      - unattended-upgrades
{% endif %}
