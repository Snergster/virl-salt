/etc/virl.ini:
  file.managed:
   - template: jinja
   - source: salt://virl/files/jinja.vsettings.ini
   - user: virl
   - group: virl
   - mode: 0755
   - unless: test -e /etc/virl.ini
