{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}


include:
  - virl.routervms.server
  - .image-symlink

{% if server and serverpref %}

Ubuntu download:
  file.managed:
    - makedirs: true
    - name: /vagrant/images/ubuntu-14.04-server-cloudimg-amd64-disk1.img
    - source: https://cloud-images.ubuntu.com/releases/14.04.4/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img
    - source_hash: https://cloud-images.ubuntu.com/releases/14.04.4/release/MD5SUMS
    - require_in:
      - glance: UbuntuServertrusty
    - require:
      - file: vagrant symlink

{% endif %}