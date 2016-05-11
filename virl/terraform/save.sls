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
{% set salt_id = salt['grains.get']('salt_id', '') %}
{% set salt_domain = salt['grains.get']('salt_domain', '') %}

{% set virl_packet_path = '/var/local/virl/virl_packet' %}

include:
  - common.salt-master.cluster-key

create sshdir for root:
  cmd.run:
    - user: root
    - group: staff
    - mode: 0700
    - name: mkdir -p ~/.ssh

copy ssh key pem:
  file.copy:
    - user: root
    - group: staff
    - mode: 0600
    - name: ~/.ssh/id_rsa
    - source: ~virl/.ssh/id_rsa
    - force: true

copy ssh key pub:
  file.copy:
    - user: root
    - group: staff
    - mode: 0600
    - name: ~/.ssh/id_rsa.pub
    - source: ~virl/.ssh/id_rsa.pub
    - force: true

{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set ifproxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% if ifproxy == True %}
https_proxy:
  environ.setenv:
    - value: {{ http_proxy }}
{% endif %}

uwm virl_packet repo:
  git.latest:
    - name: https://github.com/Snergster/virl_packet.git
    - target: {{ virl_packet_path }}

pem minion key copy:
  file.copy:
    - name: {{ virl_packet_path }}/keys/minion.pem
    - source: /etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555
    - force: true

pub minion key copy:
  file.copy:
    - name: {{ virl_packet_path }}/keys/minion.pub
    - source: /etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755
    - force: true

sign minion key copy:
  file.copy:
    - name: {{ virl_packet_path }}/keys/master_sign.pub
    - source: /etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755
    - force: true

working variable file:
  file.copy:
    - user: virl
    - group: virl
    - name: {{ virl_packet_path }}/variables.tf
    - source: {{ virl_packet_path }}/variables.tf.orig
    - force: true

working password file:
  file.copy:
    - user: virl
    - group: virl
    - name: {{ virl_packet_path }}/passwords.tf
    - source: {{ virl_packet_path }}/passwords.tf.orig
    - force: true

working api file:
  file.copy:
    - user: virl
    - group: virl
    - name: {{ virl_packet_path }}/settings.tf
    - source: {{ virl_packet_path }}/settings.tf.orig
    - force: true

# using user data
guest pass replace:
  file.replace:
    - name: {{ virl_packet_path }}/passwords.tf
    - pattern: 321guest123
    - repl: '{{ packet_guest_password }}'
    - require:
      - file: working password file

uwmadmin pass replace:
  file.replace:
    - name: {{ virl_packet_path }}/passwords.tf
    - pattern: '321uwmp123'
    - repl: '{{ packet_uwmadmin_password }}'
    - require:
      - file: working password file

os pass replace:
  file.replace:
    - name: {{ virl_packet_path }}/passwords.tf
    - pattern: '123pass321'
    - repl: '{{ packet_openstack_password }}'
    - require:
      - file: working password file

mysql pass replace:
  file.replace:
    - name: {{ virl_packet_path }}/passwords.tf
    - pattern: '123mysq321'
    - repl: '{{ packet_mysql_password }}'
    - require:
      - file: working password file

os token replace:
  file.replace:
    - name: {{ virl_packet_path }}/passwords.tf
    - pattern: '123token321'
    - repl: '{{ packet_openstack_token }}'
    - require:
      - file: working password file

hostname replace:
  file.replace:
    - name: {{ virl_packet_path }}/variables.tf
    - pattern: 'virltest'
    #- repl: '{{ salt_id }}'
    - repl: '{{ hostname }}'
    - require:
      - file: working variable file

id replace:
  file.replace:
    - name: {{ virl_packet_path }}/variables.tf
    - pattern: 'badsaltid'
    - repl: '{{ salt_id }}'
    - require:
      - file: working variable file

# no placeholders
packet_machine_type replace:
  file.replace:
    - name: {{ virl_packet_path }}/settings.tf
    - pattern: 'default = "baremetal_1"'
    - repl: 'default = "{{ packet_machine_type }}"'
    - require:
      - file: working api file
dead_mans_timer replace:
  file.replace:
    - name: {{ virl_packet_path }}/settings.tf
    - pattern: 'default = "4"'
    - repl: 'default = "{{ packet_dead_timer }}"'
    - require:
      - file: working api file
packet_location replace:
  file.replace:
    - name: {{ virl_packet_path }}/settings.tf
    - pattern: 'default = "ewr1"'
    - repl: 'default = "{{ packet_location }}"'
    - require:
      - file: working api file
# need to split, no better way to match
{% set packet_location_name = packet_location[:3] %}
{% set packet_location_num = packet_location[3:] %}
salt_master replace:
  file.replace:
    - name: {{ virl_packet_path }}/settings.tf
    - pattern: 'default = "ewr-packet-1.virl.info"'
    - repl: 'default = "{{ packet_location_name }}-packet-{{ packet_location_num }}.virl.info"'
    - require:
      - file: working api file

packet_api_key replace:
  file.replace:
    - name: {{ virl_packet_path }}/settings.tf
    - pattern: bad_api_key
    - repl: '{{ packet_api_key }}'
    - require:
      - file: working api file

domain replace:
  file.replace:
    - name: {{ virl_packet_path }}/variables.tf
    - pattern: '= "virl.info"'
    - repl: '= "{{ salt_domain }}"'
    - require:
      - file: working variable file

virl tf ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/virl.tf
    - create: false
    - user: virl
    - group: virl

virl tf backup ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/virl.tf.bak
    - create: false
    - user: virl
    - group: virl

variables tf ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/variables.tf
    - create: false
    - user: virl
    - group: virl

variables tf backup ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/variables.tf.bak
    - create: false
    - user: virl
    - group: virl

passwords tf ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/passwords.tf
    - create: false
    - user: virl
    - group: virl

passwords tf backup ownership fix:
  file.managed:
    - name: {{ virl_packet_path }}/passwords.tf.bak
    - create: false
    - user: virl
    - group: virl
