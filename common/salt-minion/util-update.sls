/usr/lib/python2.7/dist-packages/salt/utils/openstack/nova.py:
  file.managed:
    - source: 'salt://common/salt-minion/files/nova.py'
    - mode: 0644
    - onlyif: ls /usr/bin/salt-minion
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/utils/openstack/nova.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/utils/openstack/nova.py

/usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py:
  file.managed:
    - source: 'salt://common/salt-minion/files/neutron.py'
    - mode: 0644
    - onlyif: ls /usr/bin/salt-minion
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py
