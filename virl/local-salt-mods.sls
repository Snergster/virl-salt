
/usr/lib/python2.7/dist-packages/salt/modules/virl_core.py:
  file.managed:
    - mode: 644
    - source: salt://_modules/virl_core.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/modules/virl_core.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/modules/virl_core.py


/usr/lib/python2.7/dist-packages/salt/states/virl_core.py:
  file.managed:
    - mode: 644
    - source: salt://_states/virl_core.py
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/salt/states/virl_core.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/virl_core.py

