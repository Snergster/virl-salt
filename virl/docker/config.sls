{% set registry_ip = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254/xx' )).split('/')[0] %}
{% set registry_port = salt['pillar.get']('virl:docker_registry_port', salt['grains.get']('docker_registry_port', '19397' )) %}

{% from "virl.jinja" import virl with context %}

docker_config:
  file.managed:
    - name: /etc/default/docker
    - mode: 0644
    - unless: test -e /etc/default/docker

docker_config-opts:
  file.replace:
    - name: /etc/default/docker
    - pattern: '^DOCKER_OPTS.*$'
    - repl: DOCKER_OPTS="--insecure-registry={{ registry_ip }}:{{ registry_port }}"
               ## Sometimes docker service does not working OK:
               # try play around with docker arg tlsverify=false
    - flags: ['IGNORECASE', 'MULTILINE']
    - append_if_not_found: True
    - require_in:
      - module: docker_restart
docker_config-proxy:
  file.replace:
    - name: /etc/default/docker
    - pattern: '^export http_proxy.*$'
    - repl: export http_proxy={{ virl.download_proxy }}
    - flags: ['IGNORECASE', 'MULTILINE']
    - append_if_not_found: True
    - require_in:
      - module: docker_restart
docker_config-noproxy:
  file.replace:
    - name: /etc/default/docker
    - pattern: '^export no_proxy.*$'
    - repl: export no_proxy={{ registry_ip }},{{ virl.download_no_proxy }},$no_proxy
    - flags: ['IGNORECASE', 'MULTILINE']
    - append_if_not_found: True
    - require_in:
      - module: docker_restart

{% if virl.mitaka %}
docker_config-systemd-fix:
  file.managed:
    - name: /etc/systemd/system/docker.service.d/10-defaults.conf
    - mode: 0644
    - source: "salt://virl/docker/files/10-defaults.conf"
  cmd.run:
    - name: systemctl daemon-reload
{% endif %}

docker_restart:
  module.run:
    - name: service.restart
    - m_name: docker
    - require:
      - file: docker_config-opts
      - file: docker_config-proxy
      - file: docker_config-noproxy
