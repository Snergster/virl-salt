cloud config hostname hack:
  file.prepend:
    - name: /etc/cloud/cloud.cfg
    - text: 'preserve_hostname: true'
