nova-restart:
  cmd.run:
    - name: |
        su -s /bin/sh -c "glance-manage db_sync" glance
        su -s /bin/sh -c "nova-manage db sync" nova
        'dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)'
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-novncproxy restart
        service glance-registry restart
        service glance-api restart
        service keystone restart
        service neutron-server restart
        service neutron-l3-agent restart
        service neutron-dhcp-agent restart
        service neutron-metadata-agent restart
        service apache2 restart
        service cinder-scheduler restart
        service cinder-api restart
