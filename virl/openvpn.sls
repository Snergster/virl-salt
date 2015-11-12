{% set openvpn_enable = salt['grains.get']('openvpn_enable', False) %}
{% set openvpn_dir = '/etc/openvpn' %}
{% set easyrsa_key_dir = '/usr/share/easy-rsa/keys' %}
{% set easyrsa_dir = '/usr/share/easy-rsa' %}
{% set server_name = 'virl.virl.lab' %}   {# ${CFG_HOSTNAME}.${CFG_DOMAIN} #}
{% set client_name = 'client' %}

{% set openvpn_ovpn_path = '/var/local/virl/client.ovpn' %}

{% if openvpn_enable %}

  install_openvpn:
    pkg.installed:
      - pkgs:
        - openvpn
        - easy-rsa
      - refresh: false

  install_easy-rsa_download:
    file.managed:
      - name: /var/cache/apt/archives/easy-rsa_2.2.2-1_all.deb
      - source:
        - salt://files/easy-rsa_2.2.2-1_all.deb
      - source_hash: md5=b3c38caa4baae7091b7631f9cc299a89
  install_easy-rsa:
    cmd.run:
      - name: dpkg -i /var/cache/apt/archives/easy-rsa_2.2.2-1_all.deb
      - unless: dpkg -l easy-rsa | grep '^ii'

  set_keys_vars:
    cmd.run:
      - names:
        - sed -ri 's/(^export KEY_CITY=")(.*)"/\1San Jose"/' ./vars
        - sed -ri 's/(^export KEY_OU=")(.*)"/\1VIRL Sandbox"/' ./vars
        - sed -ri 's/(^export KEY_ORG=")(.*)"/\1VIRL Customer"/' ./vars
        - sed -ri 's/(^export KEY_EMAIL=")(.*)"/\1noreply@virl.info"/' ./vars
        - sed -ri 's/(^export KEY_EXPIRE=)(.*)/\13650/' ./vars
        - sed -ri 's/(^export CA_EXPIRE=)(.*)/\13650/' ./vars
      - cwd: {{ easyrsa_dir }}

  pkitool cleaner:
    cmd.run:
      - name: source ./vars && ./clean-all
      - cwd: {{ easyrsa_dir }}
      - creates: {{ easyrsa_key_dir }}/ca.crt

  init_ca:
    cmd.run:
      - require:
        - cmd: pkitool cleaner
      - name: source ./vars && ./pkitool --initca
      - cwd: {{ easyrsa_dir }}
      - creates: {{ easyrsa_key_dir }}/ca.crt

  gen_server_keys:
    cmd.run:
      - require:
        - cmd: pkitool cleaner
      - name: source ./vars && ./pkitool --server {{ server_name }}
      - cwd: {{ easyrsa_dir }}
      - creates: {{ easyrsa_key_dir }}/{{ server_name }}.key

  gen_client_keys:
    cmd.run:
      - require:
        - cmd: pkitool cleaner
      - name: source ./vars && ./pkitool {{ client_name }}
      - cwd: {{ easyrsa_dir }}
      - creates: {{ easyrsa_key_dir }}/{{ client_name }}.key

  gen_dh_file:
    cmd.run:
      - require:
        - cmd: pkitool cleaner
      - name: source ./vars && ./build-dh
      - cwd: {{ easyrsa_dir }}
      - creates: {{ easyrsa_key_dir }}/dh2048.pem

  # sync keys in easy-rsa vs. /etc/openvpn/ because admin user might change keys
  copy_keys_rsa2etc:
    cmd.run:
      - names:
        - cp ./keys/dh2048.pem {{ openvpn_dir }}
        - cp ./keys/ca.* {{ openvpn_dir }}
        - cp ./keys/{{ client_name }}.* {{ openvpn_dir }}
        - cp ./keys/{{ server_name }}.* {{ openvpn_dir }}
      - cwd: {{ easyrsa_dir }}

  {{ openvpn_dir }}/server.conf:
    file.managed:
      - mode: 644
      - template: jinja
      - source: salt://virl/files/openvpn_server.conf

  {{ openvpn_dir }}/bridge-up.sh:
    file.managed:
      - mode: 755
      - template: jinja
      - source: "salt://virl/files/bridge-up.sh"

  client_ovpn:
    cmd.script:
      - source: salt://virl/files/openvpn_client.sh
      - template: jinja

  # Change priority for OpenVPN start (default=16) but
  # at that time Neutron has not been started!
  # For the tap interface to come up successfully the
  # L3 Neutron Router Interfaces have to be configured first!
  # So we move the OpenVPN start to the end of the line.
  openvpn_remove_rc:
    cmd.run:
      - name: update-rc.d -f openvpn remove

  openvpn_reorder_rc:
    cmd.run:
      - name: update-rc.d openvpn start 99 2 3 4 5 . stop 80 0 1 6 .

  openvpn_enable:
    service.running:
      - name: openvpn
      - enable: True

  openvpn_restart:
    cmd.run:
      - name: service openvpn restart

{% else %}

  openvpn_disable:
    service.dead:
      - name: openvpn
      - enable: False

{% endif %}

