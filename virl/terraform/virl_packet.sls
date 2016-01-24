{% set hostname = salt['grains.get']('salt_id', 'virltest') %}

include:
  - common.salt-master.cluster-key

virl_packet repo:
  git.latest:
    - name: https://github.com/Snergster/virl_packet.git
    - target: /home/virl/virl_packet

install pwgen:
  pkg.installed:
    - name: pwgen

pem minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pem
    - source: file://etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555

pub minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pub
    - source: file://etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755

sign minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/master_sign.pub
    - source: file://etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755

working variable file:
  file.copy:
    - name: /home/virl/virl_packet/variables.tf
    - source: file:///home/virl/virl_packet/orig.variables.tf

guest pass replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 321guest123
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'

uwmadmin pass replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '321uwmp123'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'

os pass replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '123pass321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'

mysql pass replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '123mysq321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'

os token replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '123token321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'

id replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'virltest'
    - repl: '{{hostname}}'





