lubuntu_desktop:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - pkgs:
      - openjdk-7-jre
      - libswt-webkit-gtk-3-jni
      - libwebkitgtk-3.0-0
      - lubuntu-desktop


/usr/share/themes/Lubuntu-default:
  file.recurse:
    - source: "salt://files/Clearlooks"
    - owner: virl
    - group: virl
