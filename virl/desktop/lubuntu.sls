{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

desktop_require:
  pkg.installed:
    - skip_verify: True
    - refresh: True
    - pkgs:
      - openjdk-7-jre
      - libswt-webkit-gtk-3-jni
      - libwebkitgtk-3.0-0

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

virt-manager install:
  pkg.installed:
    - name: virt-manager

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

{% if cml %}
/home/virl/Desktop/VMMaestro.desktop absent:
  file.absent:
    - name: /home/virl/Desktop/VMMaestro.desktop

cml version because they dare to be different:
  file.managed:
    - name: /home/virl/Desktop/Edit-settings.desktop
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=0. Edit settings.ini
         Comment=To edit settings.ini file
         Exec=sudo gedit /etc/settings.ini
         Icon=/usr/share/icons/Humanity/apps/48/gedit-icon.svg
         Terminal=False
         Type=Application
         Categories=Utility;Application;

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

/home/virl/Desktop/KernelPatch.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=3. L2 Kernel Patch
         Comment=Applies kernel bridge patch
         Exec=xterm -e "/usr/local/bin/vinstall bridge | tee /var/tmp/virl-kernelpatch-log"
         Icon=/usr/share/icons/gnome/48x48/status/network-wired-disconnected.png
         Terminal=True
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
  {% if cml %}
    - source: "salt://virl/desktop/files/cmlREADME"
  {% else %}
    - source: "salt://virl/desktop/files/vREADME"
  {% endif %}
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/usr/share/themes/Lubuntu-default/openbox-3/themerc:
  file.managed:
    - source: "salt://virl/files/Clearlooks/openbox-3/themerc"
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/usr/share/themes/Lubuntu-default/gtk-2.0/gtkrc:
  file.managed:
    - source: "salt://virl/files/Clearlooks/gtk-2.0/gtkrc"
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

/home/virl/.config/pcmanfm/lubuntu/desktop-items-0.conf:
  file.managed:
    - source: "salt://virl/desktop/files/desktop-items-0.conf"
    - makedirs: true
    - user: virl
    - group: virl
    - require:
      - pkg: lubuntu-desktop

{% if cml %}
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

/etc/xdg/autostart/nm-applet.desktop:
  file.absent:
    - name: /etc/xdg/autostart/nm-applet.desktop


##      - crudini --set /home/virl/.config/libfm/libfm.conf config terminal xterm -e %s
##      - crudini --set /etc/xdg/lubuntu/libfm/libfm.conf config terminal xterm -e %s
