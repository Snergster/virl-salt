include:
  - virl.settings


{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}

testiefill:
  file.touch:
    - name: /tmp/{{uwmpassword}}

testiefill2:
  file.touch:
    - name: /tmp/{{ ks_token }}
