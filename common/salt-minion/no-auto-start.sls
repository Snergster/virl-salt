include:
  - common.salt-master.no-auto-start

salt-minion no upstart:
  file.managed:
    - name: /etc/init/salt-minion.override
    - contents: |
        start on manual
        stop on manual

salt-minion no sysv:
    cmd.run:
        - name: /usr/sbin/update-rc.d -f salt-minion remove
