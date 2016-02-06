{% set hostname = salt['grains.get']('salt_id', 'virltest') %}
{% set salt_domain = salt['grains.get']('append_domain', 'virl.info') %}

include:
  - common.salt-master.cluster-key


virl_cluster repo:
  git.latest:
    - user: virl
    - name: https://github.com/Snergster/virl_cluster.git
    - target: /home/virl/virl_cluster

cluster install pwgen:
  pkg.installed:
    - refresh: true
    - name: pwgen

cluster pem minion key copy:
  file.copy:
    - name: /home/virl/virl_cluster/keys/minion.pem
    - source: /etc/salt/pki/minion/minion.pem
    - user: virl
    - group: virl
    - mode: 0555

cluster pub minion key copy:
  file.copy:
    - name: /home/virl/virl_cluster/keys/minion.pub
    - source: /etc/salt/pki/minion/minion.pub
    - user: virl
    - group: virl
    - mode: 0755

cluster sign minion key copy:
  file.copy:
    - name: /home/virl/virl_cluster/keys/master_sign.pub
    - source: /etc/salt/pki/minion/master_sign.pub
    - user: virl
    - group: virl
    - mode: 0755

cluster working variable file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_cluster/variables.tf
    - source: /home/virl/virl_cluster/variables.tf.orig
    - force: true

cluster working password file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_cluster/passwords.tf
    - source: /home/virl/virl_cluster/passwords.tf.orig
    - force: true

cluster working api file:
  file.copy:
    - user: virl
    - group: virl
    - name: /home/virl/virl_cluster/settings.tf
    - source: /home/virl/virl_cluster/settings.tf.orig
    - force: false

cluster guest pass replace:
  file.replace:
    - name: /home/virl/virl_cluster/passwords.tf
    - pattern: 321guest123
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

cluster uwmadmin pass replace:
  file.replace:
    - name: /home/virl/virl_cluster/passwords.tf
    - pattern: '321uwmp123'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

cluster os pass replace:
  file.replace:
    - name: /home/virl/virl_cluster/passwords.tf
    - pattern: '123pass321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

cluster mysql pass replace:
  file.replace:
    - name: /home/virl/virl_cluster/passwords.tf
    - pattern: '123mysq321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

cluster os token replace:
  file.replace:
    - name: /home/virl/virl_cluster/passwords.tf
    - pattern: '123token321'
    - repl: '{{ salt['cmd.run']('/usr/bin/pwgen -c -n 10 1')}}'
    - require:
      - pkg: install pwgen
      - file: working password file

cluster hostname replace:
  file.replace:
    - name: /home/virl/virl_cluster/variables.tf
    - pattern: 'virltest'
    - repl: '{{hostname}}'

cluster id replace:
  file.replace:
    - name: /home/virl/virl_cluster/variables.tf
    - pattern: 'badsaltid'
    - repl: '{{hostname}}'

cluster domain replace:
  file.replace:
    - name: /home/virl/virl_cluster/variables.tf
    - pattern: '= "virl.info"'
    - repl: '= "{{salt_domain}}"'

cluster virl tf ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/virl.tf
    - create: false
    - user: virl
    - group: virl

cluster virl tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/virl.tf.bak
    - create: false
    - user: virl
    - group: virl

cluster variables tf ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/variables.tf
    - create: false
    - user: virl
    - group: virl

cluster variables tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/variables.tf.bak
    - create: false
    - user: virl
    - group: virl

cluster passwords tf ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/passwords.tf
    - create: false
    - user: virl
    - group: virl

cluster passwords tf backup ownership fix:
  file.managed:
    - name: /home/virl/virl_cluster/passwords.tf.bak
    - create: false
    - user: virl
    - group: virl


