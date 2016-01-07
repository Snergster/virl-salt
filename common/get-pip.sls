
get-pip:
  cmd.script:
    - source: https://bootstrap.pypa.io/get-pip.py
    - mode: 0755
    - cwd: /tmp
    - unless: test -e /usr/local/bin/pip

