
break bad gitfs locks:
  cmd.run:
    - name: 'find /var/cache/salt/master/gitfs/*/update.lk -mtime +1 -delete'
