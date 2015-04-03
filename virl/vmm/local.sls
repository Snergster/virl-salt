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

VMMdir virl owned:
  cmd.run:
    - name: 'chown -R virl:virl /home/virl/VMMaestro-linux'
    - require:
      - module: VMMlinux

vmmpkgs:
  pkg.installed:
      - pkgs:
        - openjdk-7-jre
        - libswt-webkit-gtk-3-jni
        - libwebkitgtk-1.0-0
        - unzip
