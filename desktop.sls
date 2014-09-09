lubuntu-desktop:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - require:
      - pkg: desktop_require
  cmd.wait:
    - names:
      - crudini --set /home/virl/.config/libfm/libfm.conf config terminal xterm -e %s
      - crudini --set /etc/xdg/lubuntu/libfm/libfm.conf config terminal xterm -e %s
      - crudini --set /etc/lightdm/lightdm.conf.d/20-lubuntu.conf SeatDefaults allow-guest False
    - watch:
      - pkg: lubuntu-desktop

/usr/share/themes/Lubuntu-default:
  file.recurse:
    - source: "salt://files/Clearlooks"
    - owner: virl
    - group: virl

gedit:
  pkg.installed:
    - refresh: True

desktop_require:
  pkg.installed:
    - skip_verify: True
    - refresh: True
    - pkgs:
      - openjdk-7-jre
      - libswt-webkit-gtk-3-jni
      - libwebkitgtk-3.0-0
