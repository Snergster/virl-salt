{% from "virl.jinja" import virl with context %}

/srv/salt/cml:
  file.recurse:
    - source: "salt://cml/"
    - user: virl
    - group: virl
    - exclude_pat: E@(.git)|(vmm)
    - file_mode: 755

/srv/salt/std:
  file.recurse:
    - source: "salt://std/"
    - user: virl
    - group: virl
    - exclude_pat: E@(.git)
    - file_mode: 755

pull-docker-registry:
  file.managed:
    - name: /srv/salt2/images/salt/{{ virl.registry_file }}
    - source: "salt://images/salt/{{ virl.registry_file }}
    - user: virl
    - group: virl
    - file_mode: 755

pull-docker-tap:
  file.managed:
    - name: /srv/salt2/images/salt/{{ virl.tap_file }}
    - source: "salt://images/salt/{{ virl.tap_file }}
    - user: virl
    - group: virl
    - file_mode: 755
