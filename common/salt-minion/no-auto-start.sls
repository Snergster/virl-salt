salt-minion no upstart:
  file.append:
    - name: /etc/init/salt-minion.override
    - text: |
        start on manual
        stop on manual

salt-minion no sysv:
    cmd.run:
        - name: /usr/sbin/update-rc.d -f salt-minion remove
        
