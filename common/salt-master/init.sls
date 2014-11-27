salt-master install:
  file.managed:
    - name: /home/ubuntu/install_salt.sh
    - mode: 0755
    - source: "salt://install_salt.sh"
  cmd.run:
      - name: /home/ubuntu/install_salt.sh -M -X stable
      - unless:
        - ls /usr/bin/salt-master

pki dir exists:
  file.directory:
    - name: /etc/salt/pki
    - makedirs: True

pillar dir exists:
  file.directory:
    - name: /srv/pillar
    - makedirs: True

pillar cache dir exists:
  file.directory:
    - name: /var/cache/salt/minion/files/base/pillar
    - makedirs: True

salt-master ramdisks:
  file.append:
    - name: /etc/fstab
    - text: |
        ramdisk /etc/salt/pki tmpfs rw,relatime 0 0
        ramdisk /srv/pillar tmpfs rw,relatime 0 0
        ramdisk /var/cache/salt/minion/files/base/pillar tmpfs rw,relatime 0 0

pki ramdisk mount:
  cmd.wait:
    - name: mount /etc/salt/pki
    - require:
      - file: pki dir exists
    - watch:
      - file: salt-master ramdisks

pillar ramdisk mount:
  cmd.wait:
    - name: mount /srv/pillar
    - require:
      - file: pillar dir exists
    - watch:
      - file: salt-master ramdisks

pillar cache ramdisk mount:
  cmd.wait:
    - name: mount /var/cache/salt/minion/files/base/pillar
    - require:
      - file: pillar cache dir exists
    - watch:
      - file: salt-master ramdisks


cache pillar:
  file.directory:
    - name: /var/cache/salt/minion/files/base/pillar
    - makedirs: True

srv pillar:
  file.directory:
    - name: /srv/pillar
    - makedirs: True

pki placeholder:
  file.directory:
    - name: /etc/salt/pki
    - makedirs: True
