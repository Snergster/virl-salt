{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

/usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py:
  {% if not masterless %}
  file.managed:
    - source: salt://common/salt-minion/files/neutron.py
  {% else %}
  file.copy:
    - source: /srv/salt/common/salt-minion/files/neutron.py
  {% endif %}
