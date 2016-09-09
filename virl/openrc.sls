{% from "virl.jinja" import virl with context %}

include:
  - openstack.mysql.open
  - virl.scripts

{% if virl.mitaka %}
/usr/local/bin/virl-openrc.sh:
  file.managed:
    - source: "salt://openstack/keystone/files/mitaka.admin-openrc.jinja"
    - mode: 0755
    - template: jinja


/home/virl/.bashrc:
  file.managed:
    - order: 1
    - source: salt://virl/files/mitaka.bashrc
    - user: virl
    - group: virl
    - mode: 755
{% else %}
/usr/local/bin/virl-openrc.sh:
  file.managed:
    - source: "salt://openstack/keystone/files/admin-openrc.jinja"
    - mode: 0755
    - template: jinja


/home/virl/.bashrc:
  file.managed:
    - order: 1
    - source: salt://virl/files/kilo.bashrc
    - user: virl
    - group: virl
    - mode: 755
{% endif %}


/home/virl/.bash_profile:
  file.managed:
    - order: 1
    - source: salt://virl/files/bash_profile
    - user: virl
    - group: virl
    - mode: 755

noproxy desires controller_ip:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: no_proxy_defaults,.*
    - repl: no_proxy_defaults,{{virl.controller_ip}}

{% if not virl.horizon %}

/var/www/index.html:
  file.managed:
    - source: salt://files/install_scripts/index.html
    - mode: 755

uwmport replace:
  file.replace:
    - name: /var/www/index.html
    - pattern: :\d{2,}"
    - repl: :{{ virl.uwmport }}"

{% endif %}

adminpass:
  file.replace:
    - name: /usr/local/bin/virl-openrc.sh
    - pattern: export OS_PASSWORD=.*
    - repl:  export OS_PASSWORD={{ virl.ospassword }}

adminpass2:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: export OS_PASSWORD=.*
    - repl:  export OS_PASSWORD={{ virl.ospassword }}

controllername2v3:
  cmd.run:
    - name: salt-call --local file.replace /home/virl/.bashrc pattern='http:\/\/.*:35357\/v3' repl='http://{{ virl.controller_ip }}:35357/v3'
    - unless: grep '{{ virl.controller_ip }}:35357/v3' /home/virl/.bashrc


controllernamev3:
  cmd.run:
    - name: salt-call --local file.replace /usr/local/bin/virl-openrc.sh pattern='http:\/\/.*:35357\/v3' repl='http://{{ virl.controller_ip }}:35357/v3'
    - unless: grep '{{ virl.controller_ip }}:35357/v3' /usr/local/bin/virl-openrc.sh

controllernamev2:
  cmd.run:
    - name: salt-call --local file.replace /home/virl/.bashrc pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ virl.controller_ip }}:35357/v2.0'
    - unless: grep '{{ virl.controller_ip }}:35357/v2.0' /home/virl/.bashrc


controllernamev:
  cmd.run:
    - name: salt-call --local file.replace /usr/local/bin/virl-openrc.sh pattern='http:\/\/.*:35357\/v2.0' repl='http://{{ virl.controller_ip }}:35357/v2.0'
    - unless: grep '{{ virl.controller_ip }}:35357/v2.0' /usr/local/bin/virl-openrc.sh


token:
  file.replace:
    - name: /usr/local/bin/virl-openrc.sh
    - pattern: OS_TOKEN
    - repl: {{ virl.ks_token }}

token2:
  file.replace:
    - name: /home/virl/.bashrc
    - pattern: OS_SERVICE_TOKEN=.*
    - repl: OS_SERVICE_TOKEN={{ virl.ks_token }}
