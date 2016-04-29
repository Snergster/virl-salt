{% set terraform_provider = salt['grains.get']('terraform_provider', '') %}
{% set packet_api_key = salt['grains.get']('packet_api_key', '') %}
{% set packet_location = salt['grains.get']('packet_location', '') %}
{% set packet_machine_type = salt['grains.get']('packet_machine_type', '') %}
{% set packet_dead_timer = salt['grains.get']('packet_dead_timer', '') %}
{% set packet_guest_password = salt['grains.get']('packet_guest_password', '') %}
{% set packet_uwmadmin_password = salt['grains.get']('packet_uwmadmin_password', '') %}
{% set packet_openstack_password = salt['grains.get']('packet_openstack_password', '') %}
{% set packet_mysql_password = salt['grains.get']('packet_mysql_password', '') %}
{% set packet_openstack_token = salt['grains.get']('packet_openstack_token', '') %}

# based on virl_packet.sls:
{% set hostname = salt['grains.get']('salt_id', 'virltest') %}
{% set id = salt['grains.get']('id', '') %}
{% set salt_id = salt['grains.get']('salt_id', '').split('.', 1)[0] %}
{% set salt_domain = salt['grains.get']('salt_domain', '').split('.', 1)[1] %}
# these seem to go stale
#{% set salt_id = salt['grains.get']('salt_id', '') %}
#{% set salt_domain = salt['grains.get']('salt_domain', '') %}

pem minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pem
    - source: /etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555
    - force: true

pub minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/minion.pub
    - source: /etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755
    - force: true

sign minion key copy:
  file.copy:
    - name: /home/virl/virl_packet/keys/master_sign.pub
    - source: /etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755
    - force: true

working variable file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/variables.tf
    - source: /home/virl/virl_packet/variables.tf.orig
    - force: true

working password file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/passwords.tf
    - source: /home/virl/virl_packet/passwords.tf.orig
    - force: true

working api file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_packet/settings.tf
    - source: /home/virl/virl_packet/settings.tf.orig
    - force: true

# using user data
guest pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: 321guest123
    - repl: '{{ packet_guest_password }}'
    - require:
      - file: working password file

uwmadmin pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '321uwmp123'
    - repl: '{{ packet_uwmadmin_password }}'
    - require:
      - file: working password file

os pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123pass321'
    - repl: '{{ packet_openstack_password }}'
    - require:
      - file: working password file

mysql pass replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123mysq321'
    - repl: '{{ packet_mysql_password }}'
    - require:
      - file: working password file

os token replace:
  file.replace:
    - name: /home/virl/virl_packet/passwords.tf
    - pattern: '123token321'
    - repl: '{{ packet_openstack_token }}'
    - require:
      - file: working password file

hostname replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'virltest'
    #- repl: '{{ salt_id }}'
    - repl: '{{ hostname }}'
    - require:
      - file: working variable file

id replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: 'badsaltid'
    - repl: '{{ salt_id }}'
    - require:
      - file: working variable file

# no placeholders
packet_machine_type replace:
  file.replace:
    - name: /home/virl/virl_packet/settings.tf
    - pattern: 'default = "baremetal_1"'
    - repl: 'default = "{{ packet_machine_type }}"'
    - require:
      - file: working api file
dead_mans_timer replace:
  file.replace:
    - name: /home/virl/virl_packet/settings.tf
    - pattern: 'default = "4"'
    - repl: 'default = "{{ packet_dead_timer }}"'
    - require:
      - file: working api file
packet_location replace:
  file.replace:
    - name: /home/virl/virl_packet/settings.tf
    - pattern: 'default = "ewr1"'
    - repl: 'default = "{{ packet_location }}"'
    - require:
      - file: working api file
# need to split, no better way to match
{% set packet_location_name = packet_location[:3] %}
{% set packet_location_num = packet_location[3:] %}
salt_master replace:
  file.replace:
    - name: /home/virl/virl_packet/settings.tf
    - pattern: 'default = "ewr-packet-1.virl.info"'
    - repl: 'default = "{{ packet_location_name }}-packet-{{ packet_location_num }}.virl.info"'
    - require:
      - file: working api file

packet_api_key replace:
  file.replace:
    - name: /home/virl/virl_packet/settings.tf
    - pattern: bad_api_key
    - repl: '{{ packet_api_key }}'
    - require:
      - file: working api file

domain replace:
  file.replace:
    - name: /home/virl/virl_packet/variables.tf
    - pattern: '= "virl.info"'
    - repl: '= "{{ salt_domain }}"'
    - require:
      - file: working variable file

virl tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/virl.tf
    - create: false
    - user: virl
    - group: virl

virl tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/virl.tf.bak
    - create: false
    - user: virl
    - group: virl

variables tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/variables.tf
    - create: false
    - user: virl
    - group: virl

variables tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/variables.tf.bak
    - create: false
    - user: virl
    - group: virl

passwords tf ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/passwords.tf
    - create: false
    - user: virl
    - group: virl

passwords tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_packet/passwords.tf.bak
    - create: false
    - user: virl
    - group: virl
