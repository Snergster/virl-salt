
break bad gitfs pillar locks:
  cmd.run:
    - name: 'salt-run cache.clear_git_lock git_pillar type=update'
