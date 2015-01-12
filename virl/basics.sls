include:
  - virl.host
  - virl.ntp
  - virl.web
  
/var/www/download:
  file.directory:
    - makedirs: True

/var/www/training:
  file.directory:
    - makedirs: True
