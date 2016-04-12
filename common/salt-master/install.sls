salt-master install:
  file.managed:
    - name: /tmp/install_salt.sh
    - mode: 0755
    - source: "salt://install_salt.sh"
  cmd.run:
      - name: /tmp/install_salt.sh -M -X -P stable
      - unless:
        - ls /usr/bin/salt-master
