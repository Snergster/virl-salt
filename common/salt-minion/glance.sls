
/usr/lib/python2.7/dist-packages/salt/modules/glance.py:
  file.managed:
    - source: salt://_modules/glance.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/modules/glance.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/modules/glance.py

/usr/lib/python2.7/dist-packages/salt/states/glance.py:
  file.managed:
    - source: salt://_states/glance.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/states/glance.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/glance.py
