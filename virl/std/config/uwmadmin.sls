{% from "virl.jinja" import virl with context %}

uwmadmin change:
  cmd.run:
    - names:
     {% if virl.cml %}
      - sleep 65
     {% endif %}
      - '/usr/local/bin/virl_uwm_server set-password -u uwmadmin -p {{ virl.uwmpassword }} -P {{ virl.uwmpassword }}'
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl.cfg env virl_std_password {{ virl.uwmpassword }}
      # new location
      - crudini --set /etc/virl/virl-core.ini env virl_openstack_password {{ virl.uwmpassword }}
      - crudini --set /etc/virl/virl-core.ini env virl_std_password {{ virl.uwmpassword }}
    - onlyif: 'test -e /var/local/virl/servers.db'

