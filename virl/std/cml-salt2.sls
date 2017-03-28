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

/srv/salt/images/salt:
  file.recurse:
    - source: "salt://images/salt/"
    - user: virl
    - group: virl
    - include_pat: {{ virl.registry_file }}
    - file_mode: 755