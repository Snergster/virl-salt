{% from "virl/settings.sls" import * with context %}


testiefill:
  file.touch:
    - name: /tmp/{{uwmpassword}}

testiefill2:
  file.touch:
    - name: /tmp/{{ ks_token }}
