pip on the box:
  pkg.installed:
    - name: python-pip
    - refresh: True
    - unless: ls /usr/local/bin/pip
    - require:
      - file: remove ugly hold

remove ugly hold:
  file.absent:
    - name: /etc/apt/preferences.d/python-pip
    - unless: ls /usr/local/bin/pip
