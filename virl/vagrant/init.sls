include:
  - virl.ank
  - virl.std
  - virl.guest

/usr/local/bin/vislink:
  file.managed:
    - source: salt://virl/files/vislink.sh
    - mode: 0755
