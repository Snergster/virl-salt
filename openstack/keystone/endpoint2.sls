{% set ospassword = salt['grains.get']('password', 'password') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set uwmpassword = salt['pillar.get']('behave:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}

testiefill:
  file.touch:
    - name: /tmp/{{uwmpassword}}