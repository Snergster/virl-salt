{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set crypt = salt['pillar.get']('restrictedusers:consul:crypt', salt['grains.get']('consul_crypt', '$6rUu5wzdNP0Y')) %}

/var/cache/salt/consul.zip:
  file.managed:
    - source: https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip
    - source_hash: sha256=307fa26ae32cb8732aed2b3320ed8daf02c28b50d952cbaae8faf67c79f78847
  service.dead:
    - names:
      - consul
  module.run:
    - name: archive.unzip
    - zip_file: /var/cache/salt/consul.zip
    - dest: /usr/local/bin


/usr/local/bin/consul:
  file.managed:
    - mode: 0755
    - onchanges:
      - module: /var/cache/salt/consul.zip

/usr/local/bin/process_check:
  file.managed:
    - mode: 0755
    - source: salt://common/consul/files/process_check.sh

consul group:
  group.present:
    - name: consul

consul user:
  user.present:
    - name: consul
    - require:
      - group: consul group
    - fullname: Consul user
    - shell: /bin/bash
    - home: /home/consul
    - groups:
      - consul
    - password: {{ crypt }}

{% for consuldir in ['/etc/consul.d/bootstrap','/etc/consul.d/server','/etc/consul.d/client','/var/consul','/etc/consul.d/ssl/CA'] %}
{{consuldir}}:
  file.directory:
    - require:
      - user: consul user
    - user: consul
    - group: consul
    - makedirs: True

{% endfor %}

python-consul for salt-consul:
  pip.installed:
    - name: python-consul
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}


/etc/consul.d/ssl/ca.cert:
  file.managed:
    - contents_pillar: consul:cacert
    - user: consul
    - group: consul

/etc/consul.d/ssl/consul.cert:
  file.managed:
    - contents_pillar: consul:sslcert
    - user: consul
    - group: consul

/etc/salt/minion.d/consul.conf:
  file.managed:
    - source: "salt://common/consul/files/consul.conf"
    - template: jinja

/etc/consul.d/ssl/consul.key:
  file.managed:
    - contents_pillar: consul:sslkey
    - user: consul
    - group: consul

consul:
  service:
    - running
    - order: last
    - enable: True
    - restart: True
