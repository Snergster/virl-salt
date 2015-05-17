
/etc/lightdm/lightdm.conf:
  file.touch:
    - makedirs: True
  file.append:
    - text: 'display-setup-script=/usr/local/bin/lightdm_display'

/usr/local/bin/lightdm_display:
  file.managed:
    - contents: 'xrandr --output default --mode 1024x768'
    - mode: 0755
