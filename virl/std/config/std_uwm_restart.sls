virl-std:
  service:
    - running
    - order: last
    - enable: True
    - restart: True

virl-uwm:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
