all-restart:
  cmd.run:
    - name: |
        service nova-cert restart
        service nova-api restart
        service nova-consoleauth restart
        service nova-scheduler restart
        service nova-conductor restart
        service nova-novncproxy restart
        service neutron-server restart
        service neutron-dhcp-agent restart
        service neutron-l3-agent restart
        service neutron-metadata-agent restart
        service neutron-plugin-linuxbridge-agent restart
        service keystone restart
        service glance-api restart
        service glance-registry restart
        service heat-api restart
        service heat-api-cfn restart
        service heat-engine restart

