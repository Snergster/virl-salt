salt-master install:
  file.managed:
    - name: /home/ubuntu/install_salt.sh
    - mode: 0755
    - source: "salt://install_salt.sh"
  cmd.run:
      - name: /home/ubuntu/install_salt.sh -M -X -P git v2015.8.3
      - unless:
        - ls /usr/bin/salt-master
