include:
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
