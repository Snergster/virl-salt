lubuntu-desktop:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - require:
      - pkg: desktop_require


/usr/share/themes/Lubuntu-default:
  file.recurse:
    - source: "salt://files/Clearlooks"
    - owner: virl
    - group: virl

desktop_require:
  pkg.installed:
    - skip_verify: True
    - refresh: True
    - pkgs:
      - openjdk-7-jre
      - libswt-webkit-gtk-3-jni
      - libwebkitgtk-3.0-0

