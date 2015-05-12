

xrdp:
  pkg.installed:
    - skip_verify: True
    - refresh: False
  service:
    - running
    - enable: True
    - require:
      - pkg: xrdp


/home/virl/.xsession:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
            lxsession -s LXDE -e LXDE
