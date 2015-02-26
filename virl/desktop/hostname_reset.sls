/home/virl/Desktop/HOSTNAME.desktop:
  file.managed:
    - mode: 0755
    - user: virl
    - group: virl
    - makedirs: True
    - contents: |
         [Desktop Entry]
         Version=1.0
         Name=Hostname-reset
         Comment=Hostname reset
         Exec=/usr/bin/sudo /usr/bin/salt-call --local state.sls virl.hostname
         Icon=/usr/share/icons/gnome/48x48/status/computer-fail.png
         Terminal=true
         Type=Application
         Categories=Utility;Application;
