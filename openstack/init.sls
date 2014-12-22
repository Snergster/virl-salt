
copy sls locally:
  file.recurse:
    - name: /srv/salt/openstack
    - source: salt://openstack
    
