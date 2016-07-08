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

{% if '2015' in salt['grains.get']('saltversion') %}
VMMlinux:
  module.run:
    - name: archive.cmd_unzip
    - zip_file: /var/www/download/*linux*
    - dest: /home/virl/VMMaestro-linux
    - onlyif: ls /var/www/download/*linux.gtk.x86_64.zip
    - require:
      - file: VMMdircreate
      - pkg: vmmpkgs

{% else %}

VMMlinux:
  module.run:
    - name: archive.unzip
    - zip_file: /var/www/download/*linux*
    - dest: /home/virl/VMMaestro-linux
    - onlyif: ls /var/www/download/*linux.gtk.x86_64.zip
    - require:
      - file: VMMdircreate
      - pkg: vmmpkgs

{% endif %}

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
