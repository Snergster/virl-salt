VMMdirpoof:
  file.absent:
    - order: 1
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
    - name: archive.cmd_unzip
    - zip_file: /var/www/download/{{ salt['pillar.get']('files:vmm_lx')}}
    - dest: /home/virl/VMMaestro-linux
    - onlyif: ls /var/www/download/{{ salt['pillar.get']('files:vmm_lx')}}
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

kill the printer:
  file.append:
    - name: /home/virl/VMMaestro-linux/VMMaestro.ini
    - text: '-Dorg.eclipse.swt.internal.gtk.disablePrinting'
