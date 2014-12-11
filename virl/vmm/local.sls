VMMdirpoof:
  file.absent:
    - order: 1
    - user: virl
    - group: virl
    - name: /home/virl/VMMaestro-linux

VMMdircreate:
  file.directory:
    - user: virl
    - group: virl
    - name: /home/virl/VMMaestro-linux
    - require:
      - file: VMMdirpoof

VMMlinux:
  module.run:
    - name: archive.unzip
    - zipfile: /var/www/download/*linux*
    - dest: /home/virl/VMMaestro-linux
    - onlyif: ls /var/www/download/*linux.gtk.x86_64.zip
    - require:
      - file: VMMdircreate
      - pkg: vmmpkgs

vmmpkgs:
  pkg.installed:
      - pkgs:
        - openjdk-7-jre
        - libswt-webkit-gtk-3-jni
        - libwebkitgtk-3.0-0
        - libxml2-dev
        - libxslt1-dev
