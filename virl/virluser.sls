virl-group:
  group.present:
    - name: virl

libvirtd needed:
  group.present:
    - name: libvirtd

virl-user:
  user.present:
    - name: virl
    - fullname: virl
    - name: virl
    - shell: /bin/bash
    - home: /home/virl
    - password: $6$SALTsalt$789PO2/UvvqTk1tGEj67KEOSPbQqqd9wEEBPqTrAuqNO1rTeNruN.IiVxXZX6w8kfEnt7q5eyz/aOFwlZow/b0

/home/virl/.ssh:
  file.directory:
    - user: virl
    - group: virl
    - makedirs: True
    - require:
      - user: virl-user

/etc/sudoers.d/virl:
  file.managed:
    - order: 3
    - mode: 0440
    - create: True
    - require:
      - user: virl-user

sudoer-defaults:
    file.append:
        - order: 4
        - name: /etc/sudoers.d/virl
        - require:
          - user: virl-user
        - text:
          - virl ALL=(root) NOPASSWD:ALL
          - Defaults:virl secure_path=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt:/opt/bin:/opt/support
          - Defaults env_keep += "http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL OS_PROJECT_DOMAIN_ID OS_USER_DOMAIN_ID OS_SERVICE_ENDPOINT OS_SERVICE_TOKEN OS_PROJECT_NAME"
