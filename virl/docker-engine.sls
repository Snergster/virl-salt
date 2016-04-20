## Install docker with registry running in container and docker-py for docker API
{% set registry_ip = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254/xx' )).split('/')[0] %}
{% set registry_port = salt['pillar.get']('virl:docker_registry_port', salt['grains.get']('docker_registry_port', '19397' )) %}

{% set docker_version = '1.9.1-0~trusty' %}
{% set registry_version = '2.4.0' %}
{% set registry_file = 'registry-2.4.0.tar' %}
{% set registry_file_hash = '0c79a98a8a2954c3bc04388be22ec0f5' %}
# If updating registry load registry manually into docker and get its Docker ID by issue $docker images
{% set registry_docker_ID = '0f29f840cdef' %}

{% set download_proxy = salt['pillar.get']('virl:download_proxy', salt['grains.get']('download_proxy', '')) %}
{% set download_no_proxy = salt['pillar.get']('virl:download_no_proxy', salt['grains.get']('download_no_proxy', '')) %}

{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/')) %}

# Docker:

remove_wrong_docker:
  pkg.purged:
    - name: lxc-docker

# this installs along docker-engine, using http repo instead
# docker_repository_prereq:
#   pkg.installed:
#     - refresh: False
#     - pkgs:
#       - apt-transport-https
#       - ca-certificates

docker_repository:
  file.managed:
    - name: /etc/apt/sources.list.d/virl-docker.list
    - mode: 0755
    - contents: |
        deb http://apt.dockerproject.org/repo ubuntu-trusty main
    # - require:
    #   - pkg: docker_repository_prereq

docker_repository_key:
  cmd.run:
    - names:
      - apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

docker_pin:
  file.managed:
    - name: /etc/apt/preferences.d/virl-docker
    - mode: 0755
    - contents: |
        Package: docker-engine
        Pin: version {{ docker_version }}
        Pin-Priority: 1001
    - required_in:
      - pkg: docker_install

docker_remove:
  pkg.removed:
    - name: docker-engine

docker_install:
  pkg.installed:
    - refresh: True
    - name: docker-engine
    - require:
      - file: docker_repository
      - cmd: docker_repository_key
      - file: docker_pin
      - pkg: docker_remove

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
    - repl: export http_proxy={{ download_proxy }}
    - flags: ['IGNORECASE', 'MULTILINE']
    - append_if_not_found: True
    - require_in:
      - module: docker_restart
docker_config-noproxy:
  file.replace:
    - name: /etc/default/docker
    - pattern: '^export no_proxy.*$'
    - repl: export no_proxy={{ registry_ip }},{{download_no_proxy}},$no_proxy
    - flags: ['IGNORECASE', 'MULTILINE']
    - append_if_not_found: True
    - require_in:
      - module: docker_restart

docker_restart:
  module.run:
    - name: service.restart
    - m_name: docker
    - require:
      - file: docker_config-opts
      - file: docker_config-proxy
      - file: docker_config-noproxy

# docker-py:

docker-py:
  pip.installed:
    - name: docker-py
    - upgrade: True
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}

# add registry into docker:

registry_remove:
  cmd.script:
    - source: salt://virl/files/remove_docker_registry.sh
    - env:
      REGISTRY_ID: {{ registry_docker_ID }}
      REGISTRY_IP: {{ registry_ip }}
      REGISTRY_PORT: {{ registry_port }}
    - require:
      - pkg: docker_install
      - module: docker_restart

registry_load:
  # state docker.loaded is buggy -> file.managed and cmd.run
  file.managed:
    - name: /var/cache/virl/docker/registry.tar
    - makedirs: True
    - source: salt://images/salt/{{ registry_file }}
    - source_hash: {{ registry_file_hash }}
    - unless: docker images -q | grep {{ registry_docker_ID }}
  cmd.run:
    - names:
      - docker load -i /var/cache/virl/docker/registry.tar
    - unless: docker images -q | grep '{{ registry_docker_ID }}'

registry_tag:
  cmd.run:
    - names:
      - docker tag {{ registry_docker_ID }} registry:{{ registry_version }}
    - unless: docker images | grep '^registry *{{ registry_version }} *{{ registry_docker_ID }}'
    - require:
      - cmd: registry_load

registry_run:
  # dockerio.running replaced by cmd.run due to API problems of dockerio/docker-py used versions
  cmd.run:
    - names:
      - docker run -d -p {{ registry_ip }}:{{ registry_port }}:5000 -e REGISTRY_STORAGE_DELETE_ENABLED=true -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry -v /var/local/virl/docker:/var/lib/registry --restart=always registry:{{ registry_version }}
    - require:
      - cmd: registry_tag
    # - unless: docker ps | grep "{{ registry_ip }}:{{ registry_port }}->5000/tcp"

