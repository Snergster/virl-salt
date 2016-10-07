{% set registry_ip = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254/xx' )).split('/')[0] %}
{% set registry_port = salt['pillar.get']('virl:docker_registry_port', salt['grains.get']('docker_registry_port', '19397' )) %}

{% from "virl.jinja" import virl with context %}

docker registry settings:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host docker_registry_ip {{ virl.registry_ip }}
      - crudini --set /etc/virl/common.cfg host docker_registry_port {{ virl.registry_port }}
      # new location
      - crudini --set /etc/virl/virl-core.ini host docker_registry_ip {{ virl.registry_ip }}
      - crudini --set /etc/virl/virl-core.ini host docker_registry_port {{ virl.registry_port }}

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
        Pin: version {{ virl.docker_version }}
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
