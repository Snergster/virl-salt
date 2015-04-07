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

/usr/lib/python2.7/dist-packages/salt/modules/keystone.py:
  file.managed:
    - source: 'salt://common/salt-minion/files/modules.keystone.py'
    - mode: 0644
    - onlyif: ls /usr/bin/salt-minion
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/modules/keystone.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/modules/keystone.py

/usr/lib/python2.7/dist-packages/salt/states/keystone.py:
  file.managed:
    - source: 'salt://common/salt-minion/files/states.keystone.py'
    - mode: 0644
    - require:
      - file: /usr/lib/python2.7/dist-packages/salt/modules/keystone.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/states/keystone.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/keystone.py
  service.running:
    - name: salt-minion
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/keystone.py
