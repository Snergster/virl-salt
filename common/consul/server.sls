
include:
  - .install

consul webui:
  file.managed:
    - name: /tmp/consulwebui.zip
    - source: https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip
    - source_hash: md5=eb98ba602bc7e177333eb2e520881f4f
  module.run:
    - name: archive.unzip
    - zip_file: /tmp/consulwebui.zip
    - dest: /home/consul

consul server init:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://common/consul/files/server_consul.conf
