salt-master install:
  file.managed:
    - name: /home/ubuntu/install_salt.sh
    - mode: 0755
    - source: "salt://files/install_salt.sh"
  cmd.run:
      - name: /home/ubuntu/install_salt.sh -M -X stable

salt-master ramdisks:
  file.append:
    - name: /etc/fstab
    - text: |
      'ramdisk /etc/salt/pki tmpfs rw,relatime 0 0'
      'ramdisk /srv/pillar tmpfs rw,relatime 0 0'
      
