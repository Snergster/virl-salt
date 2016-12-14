{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set domain = salt['pillar.get']('virl:domain_name', salt['grains.get']('domain_name', 'virl.info')) %}
{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' )) %}
{% set virl_cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False))%}
{% set dhcp = salt['pillar.get']('virl:using_dhcp_on_the_public_port', salt['grains.get']('using_dhcp_on_the_public_port', True )) %}


hosts new style:
  file.managed:
    - name: /etc/hosts
    - mode: 644
    - template: jinja
    - source: "salt://virl/files/hosts.jinja"

{% if not dhcp %}

vhost:
  host.present:
    - name: {{ hostname }}.{{domain}}
    - ip:
      -  {{ public_ip }}

{% endif %}

vhostname:
  file.managed:
    - name: /etc/hostname
    - contents: {{ hostname }}
  cmd.run:
    - name: /usr/bin/hostnamectl set-hostname {{ hostname }}

