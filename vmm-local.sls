VMMdirpoof:
  file.absent:
    - order: 1
    - user: virl
    - group: virl
    - name: /home/virl/VMMaestro-linux

VMMdircreate:
  file.directory:
    - order: 2
    - user: virl
    - group: virl
    - name: /home/virl/VMMaestro-linux

VMMlinux:
  module.run:
    - name: archive.unzip
    - zipfile: /var/www/download/*linux*
    - dest: /home/virl/VMMaestro-linux


vmmpkgs:
  pkg.installed:
    - order: 3
    - pkgs:
      - openjdk-7-jre
      - libswt-webkit-gtk-3-jni
      - libwebkitgtk-3.0-0
      - libxml2-dev
      - libxslt1-dev
