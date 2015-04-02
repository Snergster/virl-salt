{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

lubuntu-desktop:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - require:
      - pkg: desktop_require
  cmd.wait:
    - names:
      - crudini --set /etc/lightdm/lightdm.conf.d/20-lubuntu.conf SeatDefaults allow-guest False
    - watch:
      - pkg: lubuntu-desktop

/home/virl/.config/libfm/libfm.conf:
  file.managed:
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
            [terminal]
            xterm -e %s

/etc/xdg/lubuntu/libfm/libfm.conf:
  file.managed:
    - makedirs: True
    - contents: |
            [terminal]
            xterm -e %s

/home/virl/Desktop/Xterm.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=xterm
         Comment=xterm for folks
         Exec=/usr/bin/xterm
         Icon=/usr/share/icons/Humanity/apps/48/utilities-terminal.svg
         Terminal=false
         Type=Application
         Categories=Utility;Application;

{% if cml == true %}
/home/virl/Desktop/CML.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=CML
         Comment=CML for folks
         Exec=/home/virl/VMMaestro-linux/CML
         Icon=/home/virl/VMMaestro-linux/icon.xpm
         Terminal=false
         Type=Application
         Categories=Utility;Application;

/home/virl/Desktop/VMMaestro.desktop absent:
  file.absent:
    - name: /home/virl/Desktop/VMMaestro.desktop

{% else %}

/home/virl/Desktop/VMMaestro.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=VMMaestro
         Comment=VMMaestro for folks
         Exec=/home/virl/VMMaestro-linux/VMMaestro
         Icon=/home/virl/VMMaestro-linux/icon.xpm
         Terminal=false
         Type=Application
         Categories=Utility;Application;

{% endif %}

/home/virl/Desktop/VIRL-rehost.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=1. Install networking
         Comment=To finish install
         Exec=xterm -e "/usr/local/bin/vinstall rehost | tee /var/tmp/virl-rehost-log"
         Icon=/usr/share/icons/gnome/48x48/status/network-wired-disconnected.png
         Terminal=True
         Type=Application
         Categories=Utility;Application;


/home/virl/Desktop/Logout.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=LOGOUT
         Comment=Easy logout button
         Exec=/usr/bin/lubuntu-logout
         Icon=/usr/share/icons/gnome/48x48/status/computer-fail.png
         Terminal=False
         Type=Application
         Categories=Utility;Application;

/home/virl/Desktop/Reboot2.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=2. REBOOT
         Comment=To reboot
         Exec=sudo /sbin/reboot
         Icon=/usr/share/icons/gnome/48x48/status/computer-fail.png
         Terminal=False
         Type=Application
         Categories=Utility;Application;


/home/virl/Desktop/IP-ADDRESS.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=ip-address
         Comment=To see host ip address
         Exec=xterm -e "/sbin/ifconfig eth0 | grep inet ;bash"
         Icon=/usr/share/icons/Humanity/apps/logviewer.svg
         Terminal=False
         Type=Application
         Categories=Utility;Application;

/home/virl/Desktop/README.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=README
         Comment=Readme for install
         Exec=gedit /home/virl/.README
         Icon=/usr/share/icons/Humanity/apps/48/accessories-dictionary.svg
         Terminal=False
         Type=Application
         Categories=Utility;Application;

/home/virl/Desktop/Edit-settings.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=0. Edit virl.ini
         Comment=To edit virl.ini file
         Exec=sudo gedit /etc/virl.ini
         Icon=/usr/share/icons/Humanity/apps/48/gedit-icon.svg
         Terminal=False
         Type=Application
         Categories=Utility;Application;

/home/virl/.config/autostart/kvmchecker.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Name=kvmchecker
         Comment=verify vt-x support
         Exec=/usr/local/bin/kvmchecker
         Hidden=false
         NoDisplay=false
         X-GNOME-Autostart-enabled=true
         Type=Application

/home/virl/.config/autostart/screensaver-settings.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Name=Screensaver
         Comment=killing energystar and screen blanker
         Exec=/usr/bin/xset -dpms s noblank s off
         Hidden=false
         NoDisplay=false
         X-GNOME-Autostart-enabled=true
         Type=Application

/usr/share/themes/Lubuntu-default:
  file.recurse:
    - source: "salt://virl/files/Clearlooks"
    - user: virl
    - group: virl
    - unless: 'test -e /srv/salt/virl/files/Clearlooks'

/home/virl/.README:
  file.managed:
  {% if cml == true %}
    - source: "salt://virl/desktop/files/cmlREADME"
  {% else %}
    - source: "salt://virl/desktop/files/vREADME"
  {% endif %}
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/usr/share/themes/Lubuntu-default/openbox-3/themerc:
  {% if masterless == false %}
  file.managed:
    - source: "salt://virl/files/Clearlooks/openbox-3/themerc"
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/Clearlooks/openbox-3/themerc
  {% endif %}
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/usr/share/themes/Lubuntu-default/gtk-2.0/gtkrc:
  {% if masterless == false %}
  file.managed:
    - source: "salt://virl/files/Clearlooks/gtk-2.0/gtkrc"
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/Clearlooks/gtk-2.0/gtkrc
  {% endif %}
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf:
  {% if masterless == false %}
  file.managed:
    - source: "salt://virl/desktop/files/desktop-items-0.conf"
  {% else %}
  file.copy:
    - source: /srv/salt/virl/desktop/files/desktop-items-0.conf
  {% endif %}
    - makedirs: true
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

{% if cml == true %}
cml background:
  openstack_config.present:
    - order: last
    - filename: /home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf
    - section: '*'
    - parameter: 'wallpaper'
    - value: '/srv/salt/virl/files/CML.jpg'
    - onlyif: 'test -e /srv/salt/virl/files/CML.jpg'
    - require:
      - file: /home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf
{% else %}
virl background:
  openstack_config.present:
    - order: last
    - filename: /home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf
    - section: '*'
    - parameter: 'wallpaper'
    - value: '/srv/salt/virl/files/virl.jpg'
    - onlyif: 'test -e /srv/salt/virl/files/virl.jpg'
    - require:
      - file: /home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf
{% endif %}

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


##      - crudini --set /home/virl/.config/libfm/libfm.conf config terminal xterm -e %s
##      - crudini --set /etc/xdg/lubuntu/libfm/libfm.conf config terminal xterm -e %s
