## Install docker with registry running in container and docker-py for docker API
{% set registry_ip = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254/xx' )).split('/')[0] %}
{% set registry_port = salt['pillar.get']('virl:docker_registry_port', salt['grains.get']('docker_registry_port', '19397' )) %}
# Version specific setting (specif. versions of docker (1.7.1), docker-py (1.4.0) and registry (2.0.1) due to used version of CoreOS 1.7.1)
{% set docker_version = '1.7.1' %}
{% set docker_file = 'docker-engine-1.7.1.deb' %}
{% set docker_hash = 'f9a045be56c6bf6e3aa0f75b41c4f2fb' %}
{% set docker_py_file = 'docker_py-1.4.0-py2-none-any.whl' %}
{% set docker_py_ver = 'docker-py==1.4.0' %}
{% set registry_version = '2.0.1' %}
{% set registry_file = 'registry-2.0.1.tar' %}
{% set registry_file_hash = '70cf7524959cabfbb0f21ead98ecfa24' %}
# If updating registry load registry manually into docker and get its Docker ID by issue $docker images
{% set registry_docker_ID = 'f9684be4155a' %}

# Docker:

remove_wrong_docker:
  pkg.purged:
    - name: lxc-docker

download_docker-engine:
  file.managed:
    - name: /var/cache/apt/archives/{{ docker_file }}
    - makedirs: True
    - source:
      - salt://virl/files/{{ docker_file }}
    - source_hash: md5={{ docker_hash }}

install_docker-engine:
  cmd.run:
    - name: dpkg -i /var/cache/apt/archives/{{ docker_file }}
    - unless: dpkg -l docker-engine | grep '^ii.*{{ docker_version }}'

config_docker:
  file.replace:
    - name: /etc/default/docker
    - pattern: '^DOCKER_OPTS.*$'
    - repl: DOCKER_OPTS="--insecure-registry={{ registry_ip }}:{{ registry_port }}"
               ## Sometimes docker service does not working OK:
               # try play around with docker arg tlsverify=false
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - require_in:
      - module: restart_docker_service

restart_docker_service:
  module.run:
    - name: service.restart
    - m_name: docker

# docker-py:

docker-py:
  file.managed:
    - name: /usr/share/python-wheels/{{ docker_py_file }}
    - makedirs: True
    - source: salt://virl/files/{{ docker_py_file }}
    - unless: pip freeze | grep {{ docker_py_ver }}
  cmd.run:
    - name: pip install /usr/share/python-wheels/{{ docker_py_file }}
    - unless: pip freeze | grep {{ docker_py_ver }}

# add registry into docker:

load_registry:
  # state docker.loaded is buggy -> file.managed and cmd.run
  file.managed:
    - name: /usr/share/{{ registry_file }}
    - source: salt://virl/files/{{ registry_file }}
    - source_hash: {{ registry_file_hash }}
    - unless: docker images | grep registry\ *{{ registry_version }}
  cmd.run:
    - names:
      - docker load -i /usr/share/{{ registry_file }} 
      - docker tag {{ registry_docker_ID }} registry:{{ registry_version }}
    - unless: docker images | grep registry\ *{{ registry_version }}

run_registry:
  # dockerio.running replaced by cmd.run due to API problems of dockerio/docker-py used versions
  cmd.run:
    - names:
      - docker run -d -p {{ registry_ip }}:{{ registry_port }}:5000 -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry -v /var/local/virl/docker:/var/lib/registry --restart=always registry:{{ registry_version }}
    - require:
      - cmd: load_registry
    - unless: docker ps | grep "{{ registry_ip }}:{{ registry_port }}->5000/tcp"

