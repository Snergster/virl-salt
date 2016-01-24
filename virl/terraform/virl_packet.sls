{% set hostname = salt['grains.get']('salt_id', 'virltest') %}
{% set salt_domain = salt['grains.get']('append_domain', 'virl.info') %}

include:
  - common.salt-master.cluster-key

remove altered virl template:
  file.absent:
    - name: /home/virl/virl_packet/virl.tf
    - onlyif: test -e /home/virl/virl_packet/virl.tf

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
    - source: /etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555

pub minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pub
    - source: /etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755

sign minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/master_sign.pub
    - source: /etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755

working variable file:
  file.copy:
    - name: /home/virl/virl_packet/variables.tf
    - source: /home/virl/virl_packet/orig.variables.tf
    - force: true

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

hostname replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'virltest'
    - repl: '{{hostname}}'

id replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'badsaltid'
    - repl: '{{hostname}}'

domain replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'virl.info'
    - repl: '{{salt_domain}}'


add ssh section:
  file.blockreplace:
    - name: /home/virl/virl_packet/virl.tf
    - marker_start: '#ssh key addition block start'
    - marker_end: '#ssh key addition block end'
    - content:  |
         resource "packet_ssh_key" "virlkey" {
         name = "virlkey"
         public_key = "${file("/home/virl/.ssh/id_rsa.pub")}"
         }



