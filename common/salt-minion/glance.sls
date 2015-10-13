
/usr/lib/python2.7/dist-packages/salt/modules/glance.py:
  file.managed:
    - source: salt://_modules/baseproxy.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/modules/glance.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/modules/glance.py

