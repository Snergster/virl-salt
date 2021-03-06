{% from "virl.jinja" import virl with context %}

{% if virl.proxy %}
http_proxy unset:
  environ.setenv:
    - name: http_proxy
    - value: False
    - false_unsets: True

https_proxy unset:
  environ.setenv:
    - name: https_proxy
    - value: False
    - false_unsets: True

{% endif %}


/var/cache/virl/std:
  file.recurse:
      {% if virl.cml %}
    - source: "salt://cml/std/{{virl.venv}}/"
    - name: /var/cache/virl/std
      {% else %}
    - source: "salt://virl/std/{{virl.venv}}/"
    - name: /var/cache/virl/std
      {% endif %}
    - clean: true
    - show_diff: False
    - user: virl
    - group: virl
    - file_mode: 755


uwm_init:
  file.managed:
{% if virl.mitaka %}
    - name: /etc/systemd/system/virl-uwm.service
    - source: "salt://virl/std/files/virl-uwm.service"
{% else %}
    - name: /etc/init.d/virl-uwm
    - source: "salt://virl/std/files/virl-uwm.init"
{% endif %}
    - mode: 0755

std_init:
  file.managed:
{% if virl.mitaka %}
    - name: /etc/systemd/system/virl-std.service
    - source: "salt://virl/std/files/virl-std.service"
{% else %}
    - name: /etc/init.d/virl-std
    - source: "salt://virl/std/files/virl-std.init"
{% endif %}
    - mode: 0755

{% if not virl.cml %}

std doc cleaner:
  file.directory:
    - name: /var/www/doc
    - clean: True

uwm packet dir:
  file.directory:
    - name: /var/local/virl/virl_packet
    - makedirs: True

{% endif %}

std docs:
  archive.extracted:
    - name: /var/www/doc/
    {% if virl.cml %}
    - source: "salt://cml/std/{{virl.venv}}/doc/html_ext.tar.gz"
    {% else %}
    - source: "salt://virl/std/{{virl.venv}}/doc/html_ext.tar.gz"
    {% endif %}
    - archive_format: tar
    - if_missing: /var/www/doc/index.html
{% if virl.salt_minor_version == 11 %}
    - enforce_toplevel: false
{% endif %}
{% if not virl.cml %}
    - require:
      - file: std doc cleaner
{% endif %}

std docs redo:
  archive.extracted:
    - name: /var/www/doc/
    {% if virl.cml %}
    - source: "salt://cml/std/{{virl.venv}}/doc/html_ext.tar.gz"
    {% else %}
    - source: "salt://virl/std/{{virl.venv}}/doc/html_ext.tar.gz"
    {% endif %}
    - archive_format: tar
    - if_missing: /var/www/doc/index.html
    - onfail: 
      - archive: std docs


careful apache2 restart:
  cmd.wait:
    - name: service apache2 restart
    - watch:
      - archive: std docs redo
      - archive: std docs 

{% if virl.mitaka %}
virl_webmux_init:
  file.managed:
    - name: /etc/systemd/system/virl-webmux.service
    - source: "salt://virl/std/files/virl-webmux.service"
    - mode: 0755
{% else %}
virl_webmux_init:
  file.managed:
    - name: /etc/init/virl-webmux.conf
    - source: "salt://virl/std/files/virl-webmux.conf"
    - mode: 0755
{% endif %}

/etc/virl directory:
  file.directory:
    - name: /etc/virl
    - dir_mode: 755

/etc/virl/common.cfg:
  file.touch:
    - require:
      - file: /etc/virl directory
    - onlyif: 'test ! -e /etc/virl/common.cfg'


/etc/virl/virl.cfg:
  file.managed:
    - replace: false
    - makedirs: true
    - mode: 0644

/etc/virl/virl-core.ini:
  file.managed:
    - replace: false
    - makedirs: true
    - mode: 0644

{% if virl.mitaka %}
virl systemd reload:
  cmd.run:
    - name: systemctl daemon-reload
{% else %}
/etc/rc2.d/S98virl-std:
  file.symlink:
    - target: /etc/init.d/virl-std
    - mode: 0755

/etc/rc2.d/S98virl-uwm:
  file.symlink:
    - target: /etc/init.d/virl-uwm
    - mode: 0755
{% endif %}

std uwm port replace:
  file.replace:
      - name: /var/www/html/index.html
      - pattern: :\d{2,}"
      - repl: :{{ virl.uwmport }}"
      - unless: grep {{ virl.uwmport }} /var/www/html/index.html

std nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'port_range'
    - value: '{{ virl.serstart }}:{{ virl.serend }}'


VIRL_CORE_dead:
  service.dead:
    - names:
      - virl-std
      - virl-uwm
    - prereq:
      - pip: VIRL_CORE
{% if not virl.mitaka %}
    - require:
      - file: /etc/rc2.d/S98virl-std
      - file: /etc/rc2.d/S98virl-uwm
{% endif %}

VIRL_CORE:
  pip.installed:
    - use_wheel: True
    - no_index: True
    - pre_releases: True
    - no_deps: True
    {% if virl.cml %}
    - find_links: "file:///var/cache/virl/std"
    - name: CML_CORE
    {% else %}
    - name: VIRL_CORE
    - find_links: "file:///var/cache/virl/std"
    - upgrade: True
    {% endif %}
  cmd.run:
    - names:
     {% if virl.cml %}
      - echo /usr/local/bin/virl_config lsb-links | at now + 1 min
     {% endif %}
      - crudini --set /etc/virl/common.cfg orchestration network_security_groups False
      - crudini --set /etc/virl/common.cfg orchestration network_custom_floating_ip True
      # new location
      - crudini --set /etc/virl/virl-core.ini orchestration network_security_groups False
      - crudini --set /etc/virl/virl-core.ini orchestration network_custom_floating_ip True
     {% if virl.enable_cinder %}
      - crudini --set /etc/virl/common.cfg orchestration volume_service True
      # new location
      - crudini --set /etc/virl/virl-core.ini orchestration volume_service True
     {% else %}
      - crudini --set /etc/virl/common.cfg orchestration volume_service False
      # new location
      - crudini --set /etc/virl/virl-core.ini orchestration volume_service False
     {% endif %}
      - /usr/local/bin/virl_config update --global
      - crudini --set /etc/virl/virl.cfg env virl_openstack_auth_url http://localhost:5000/{{ virl.keystone_auth_version }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ virl.ks_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ virl.stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ virl.stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ virl.uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ virl.uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_user_name uwmadmin
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' snat_net_dns {{ virl.fdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' snat_net_dns2 {{ virl.sdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' mgmt_net_dns {{ virl.fdns }}
      - crudini --set /etc/virl/virl.cfg 'new-project-networks' mgmt_net_dns2 {{ virl.sdns }}
      - crudini --set /etc/virl/virl.cfg env virl_webmux_port {{ virl.virl_webmux }}
      - crudini --del /etc/virl/virl.cfg env virl_local_ip
      - crudini --set /etc/virl/common.cfg host webmux_port {{ virl.virl_webmux }}
      - crudini --set /etc/virl/common.cfg host ank_live_port {{ virl.ank_live }}
      - crudini --set /etc/virl/common.cfg host download_proxy {{ virl.download_proxy }}
      - crudini --set /etc/virl/common.cfg host download_no_proxy {{ virl.download_no_proxy }}
      - crudini --set /etc/virl/common.cfg host download_proxy_user {{ virl.download_proxy_user }}
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_min_tcp {{ virl.host_simulation_port_min_tcp }}
      - crudini --set /etc/virl/common.cfg limits host_simulation_port_max_tcp {{ virl.host_simulation_port_max_tcp }}
      - crudini --set /etc/virl/common.cfg host ram_overcommit {{ virl.ram_overcommit }}
      - crudini --set /etc/virl/common.cfg host cpu_overcommit {{ virl.cpu_overcommit }}
      # new location
      - crudini --set /etc/virl/virl-core.ini env virl_openstack_auth_url http://localhost:5000/{{ virl.keystone_auth_version }}
      - crudini --set /etc/virl/virl-core.ini env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl-core.ini env virl_openstack_service_token {{ virl.ks_token }}
      - crudini --set /etc/virl/virl-core.ini env virl_std_port {{ virl.stdport }}
      - crudini --set /etc/virl/virl-core.ini env virl_std_url http://localhost:{{ virl.stdport }}
      - crudini --set /etc/virl/virl-core.ini env virl_uwm_port {{ virl.uwmport }}
      - crudini --set /etc/virl/virl-core.ini env virl_uwm_url http://localhost:{{ virl.uwmport }}
      - crudini --set /etc/virl/virl-core.ini env virl_std_user_name uwmadmin
      - crudini --set /etc/virl/virl-core.ini env virl_std_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl-core.ini 'new-project-networks' snat_net_dns {{ virl.fdns }}
      - crudini --set /etc/virl/virl-core.ini 'new-project-networks' snat_net_dns2 {{ virl.sdns }}
      - crudini --set /etc/virl/virl-core.ini 'new-project-networks' mgmt_net_dns {{ virl.fdns }}
      - crudini --set /etc/virl/virl-core.ini 'new-project-networks' mgmt_net_dns2 {{ virl.sdns }}
      - crudini --set /etc/virl/virl-core.ini env virl_webmux_port {{ virl.virl_webmux }}
      - crudini --set /etc/virl/virl-core.ini host webmux_port {{ virl.virl_webmux }}
      - crudini --set /etc/virl/virl-core.ini host ank_live_port {{ virl.ank_live }}
      - crudini --set /etc/virl/virl-core.ini host download_proxy {{ virl.download_proxy }}
      - crudini --set /etc/virl/virl-core.ini host download_no_proxy {{ virl.download_no_proxy }}
      - crudini --set /etc/virl/virl-core.ini host download_proxy_user {{ virl.download_proxy_user }}
      - crudini --set /etc/virl/virl-core.ini host horizon {{ virl.horizon }}
      - crudini --set /etc/virl/virl-core.ini limits host_simulation_port_min_tcp {{ virl.host_simulation_port_min_tcp }}
      - crudini --set /etc/virl/virl-core.ini limits host_simulation_port_max_tcp {{ virl.host_simulation_port_max_tcp }}
      - crudini --set /etc/virl/virl-core.ini host ram_overcommit {{ virl.ram_overcommit }}
      - crudini --set /etc/virl/virl-core.ini host cpu_overcommit {{ virl.cpu_overcommit }}
      - crudini --del /etc/virl/virl-core.ini env virl_local_ip
     {% if virl.mitaka %}
      - crudini --set /etc/virl/virl-core.ini linuxbridge bridge_flat br1
      - crudini --set /etc/virl/virl-core.ini linuxbridge bridge_flat1 br2
      - crudini --set /etc/virl/virl-core.ini linuxbridge bridge_ext-net br3
     {% endif %}
     {% if virl.salt_transport_tcp %}
      - crudini --set /etc/virl/common.cfg licensing offered_salt_masters {{ virl.salt_master_tcp_default }}
      # new location
      - crudini --set /etc/virl/virl-core.ini licensing offered_salt_masters {{ virl.salt_master_tcp_default }}
     {% else %}
      - crudini --set /etc/virl/common.cfg licensing offered_salt_masters {{ virl.salt_master_default }}
      # new location
      - crudini --set /etc/virl/virl-core.ini licensing offered_salt_masters {{ virl.salt_master_default }}
     {% endif %}

ank_live_port change:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host ank_live_port {{ virl.ank_live }}
      # new location
      - crudini --set /etc/virl/virl-core.ini host ank_live_port {{ virl.ank_live }}

ank preview port:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host ank_preview_port {{ virl.ank }}
      # new location
      - crudini --set /etc/virl/virl-core.ini host ank_preview_port {{ virl.ank }}

web editor alpha:
{% if virl.web_editor %}
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host topology_editor_port {{ virl.ank }}
      # new location
      - crudini --set /etc/virl/virl-core.ini host topology_editor_port {{ virl.ank }}
{% else %}
  file.replace:
    - name: /etc/virl/common.cfg
    - pattern: '^topology_editor_port.*'
    - repl: ''
{% endif %}

{% if virl.cluster %}
enable cluster in std :
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg orchestration cluster_mode True
      # new location
      - crudini --set /etc/virl/virl-core.ini orchestration cluster_mode True
    - require:
      - pip: VIRL_CORE

point std at key:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg cluster ssh_key '~virl/.ssh/id_rsa'
      # new location
      - crudini --set /etc/virl/virl-core.ini cluster ssh_key '~virl/.ssh/id_rsa'
    - onlyif:
      - test -e ~virl/.ssh/id_rsa.pub
      - test -e /etc/virl/common.cfg
    - require:
      - pip: VIRL_CORE

  {% set compute_hostnames = [] %}
  {% if virl.compute1_active and compute_hostnames.append(virl.compute1_hostname) %}{% endif %}
  {% if virl.compute2_active and compute_hostnames.append(virl.compute2_hostname) %}{% endif %}
  {% if virl.compute3_active and compute_hostnames.append(virl.compute3_hostname) %}{% endif %}
  {% if virl.compute4_active and compute_hostnames.append(virl.compute4_hostname) %}{% endif %}
  {% set compute_hostnames = ','.join(compute_hostnames) %}

set clusters in std:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg cluster computes '{{compute_hostnames}}'
      # new location
      - crudini --set /etc/virl/virl-core.ini cluster computes '{{compute_hostnames}}'
    - require:
      - pip: VIRL_CORE

{% endif %}

webmux_port change:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_webmux_port {{ virl.virl_webmux }}
      - crudini --set /etc/virl/common.cfg host webmux_port {{ virl.virl_webmux }}
      # new location
      - crudini --set /etc/virl/virl-core.ini env virl_webmux_port {{ virl.virl_webmux }}
      - crudini --set /etc/virl/virl-core.ini host webmux_port {{ virl.virl_webmux }}
      - service virl-webmux restart

uwmadmin change:
  cmd.run:
    - names:
     {% if virl.cml %}
      - sleep 65
     {% endif %}
      - '/usr/local/bin/virl_uwm_server set-password -u uwmadmin -p {{ virl.uwmpassword }} -P {{ virl.uwmpassword }}'
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ virl.uwmpassword }}
      # new location
      - crudini --set /etc/virl/virl-core.ini env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl-core.ini env virl_std_password {{ virl.uwmpassword }}
    - onlyif: 'test -e /var/local/virl/servers.db'

virl init:
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/{{ virl.keystone_auth_version }} -u uwmadmin -p {{ virl.uwmpassword }} -U uwmadmin -P {{ virl.uwmpassword }} -T uwmadmin
    - onlyif: 'test ! -e /var/local/virl/servers.db'

virl init second:
  cmd:
    - run
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/{{ virl.keystone_auth_version }} -u uwmadmin -p {{ virl.uwmpassword }} -U uwmadmin -P {{ virl.uwmpassword }} -T uwmadmin
    - onlyif: 'test ! -e /var/local/virl/servers.db'
    - onfail:
      - cmd: uwmadmin change

virl db upgrade init:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_server upgrade
    - require:
      - pip: VIRL_CORE

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

virl init failsafe:
  cmd.run:
    - name: /usr/local/bin/virl_uwm_server init -A http://127.0.1.1:5000/{{ virl.keystone_auth_version }} -u uwmadmin -p {{ virl.uwmpassword }} -U uwmadmin -P {{ virl.uwmpassword }} -T uwmadmin
    - onlyif: 'test ! -e /var/local/virl/servers.db'
    - require:
      - service: virl-uwm
      - service: virl-std

inotify max instances:
  file.append:
  {% if virl.mitaka %}
   - name: /etc/sysctl.d/30-tracker.conf
   {% else %}
   - name: /etc/sysctl.conf
   {% endif %}
   - text: "fs.inotify.max_user_instances=1024"

inotify sysctl restart:
  cmd.run:
    - name: 'sysctl -p'
    - onchanges:
    {% if virl.mitaka %}
      - file: /etc/sysctl.d/30-tracker.conf
      {% else %}
      - file: /etc/sysctl.conf
      {% endif %}
