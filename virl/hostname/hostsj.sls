
/etc/hosts:
  file.managed:
    - mode: 644
    - template: jinja
    - source: "salt://virl/files/hosts.jinja"
