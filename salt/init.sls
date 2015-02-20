/usr/lib/python2.7/dist-packages/salt/utils/openstack/nova.py:
  file.managed:
    - source: 'salt://salt/files/nova.py'
    - mode: 0644
    - onlyif: ls /usr/bin/salt-minion
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/utils/openstack/nova.py
    - watch:
      - file: /usr/local/lib/python2.7/dist-packages/salt/utils/openstack/nova.py

/usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py:
  file.managed:
    - source: 'salt://salt/files/neutron.py'
    - mode: 0644
    - onlyif: ls /usr/bin/salt-minion
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py
    - watch:
      - file: /usr/local/lib/python2.7/dist-packages/salt/utils/openstack/neutron.py
