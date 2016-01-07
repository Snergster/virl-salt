salt-minion no upstart:
  file.managed:
    - name: /etc/salt/minion.d/alive.conf
    - contents: |
        master_alive_interval: 600
  cmd.run:
    - name: service salt-minion restart

