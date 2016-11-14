salt-master no upstart:
  file.managed:
    - name: /etc/init/salt-master.override
    - contents: |
        start on manual
        stop on manual

salt-master no sysv:
    cmd.run:
        - name: /usr/sbin/update-rc.d -f salt-master remove

salt-master no autostart:
    cmd.run:
        - name: /bin/systemctl disable salt-master
