

virl-std dead:
  service.dead:
    - name: virl-std

virl-uwm dead:
  service.dead:
    - name: virl-uwm

uwm no upstart:
  file.absent:
    - name: /etc/init.d/virl-uwm
    - require:
      - service: virl-uwm dead

std no upstart:
  file.absent:
    - name: /etc/init.d/virl-std
    - require:
      - service: virl-std dead

remove virl-core:
  pip_state.removed:
    - name: VIRL-CORE
    - require:
      - service: virl-std dead
      - service: virl-uwm dead

remove msg file:
  file.absent:
    - name: /var/local/virl/master.msg
    - require:
      - service: virl-std dead
      - service: virl-uwm dead

std cache cleanup:
  cmd.run:
    - names:
      - 'rm -f /var/cache/virl/std/VIRL*'
      - 'rm -rf /var/cache/virl/std/doc'

