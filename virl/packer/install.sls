{% if salt['grains.get']('cpuarch') != 'x86_64' %}

download packer:
  file.managed:
    - name: /home/virl/packer_0.9.0_linux_386.zip
    - source: https://releases.hashicorp.com/packer/0.9.0/packer_0.9.0_linux_386.zip
    - source_hash: https://releases.hashicorp.com/packer/0.9.0/packer_0.9.0_SHA256SUMS
    - unless: packer --version  | grep 'v0.9.0'
install packer:
  cmd.run:
    - name: unzip -o /home/virl/packer_0.9.0_linux_386.zip -d /usr/local/bin
    - unless: packer --version  | grep 'v0.9.0'
    - require:
      - file: download packer

remove dead zipfile:
  file.absent:
    - name: /home/virl/packer_0.9.0_linux_386.zip
    - require:
      - cmd: install packer

{% else %}

download packer:
  file.managed:
    - name: /home/virl/packer_0.9.0_linux_amd64.zip
    - source: https://releases.hashicorp.com/packer/0.9.0/packer_0.9.0_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/packer/0.9.0/packer_0.9.0_SHA256SUMS
    - unless: packer --version  | grep 'v0.9.0'
install packer:
  cmd.run:
    - name: unzip -o /home/virl/packer_0.9.0_linux_amd64.zip -d /usr/local/bin
    - unless: packer --version  | grep 'v0.9.0'
    - require:
      - file: download packer

remove dead zipfile:
  file.absent:
    - name: /home/virl/packer_0.9.0_linux_amd64.zip
    - require:
      - cmd: install packer

{% endif %}