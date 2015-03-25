include:
  - virl.vsalt
  - virl.vextra
  - virl.host
  - virl.ntp
  - virl.web


/var/www/download exists:
  file.directory:
    - name: /var/www/download
    - makedirs: True

/var/www/training exists:
  file.directory:
    - name: /var/www/training
    - makedirs: True

prefer ipv4:
  file.append:
    - name: /etc/gai.conf
    - text: 'precedence ::ffff:0:0/96  100'
