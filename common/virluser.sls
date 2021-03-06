virl-group:
  group.present:
    - name: virl

virl-user:
  user.present:
    - name: virl
    - fullname: virl
    - name: virl
    - shell: /bin/bash
    - home: /home/virl
    - password: $6$SALTsalt$789PO2/UvvqTk1tGEj67KEOSPbQqqd9wEEBPqTrAuqNO1rTeNruN.IiVxXZX6w8kfEnt7q5eyz/aOFwlZow/b0

/etc/sudoers.d/virl:
  file.managed:
    - mode: 0440
    - create: True
    - contents: |
         virl ALL=(root) NOPASSWD:ALL
         Defaults:virl secure_path=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt:/opt/bin:/opt/support
         Defaults env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL"
  