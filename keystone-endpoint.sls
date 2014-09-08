{% set ospassword = salt['grains.get']('password', 'password') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set uwmpassword = salt['grains.get']('uwmadmin_password', 'password') %}

glance endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0 --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ image / {print $2}') --publicurl=http://{{ public_ip }}:9292 --internalurl=http://{{ public_ip }}:9292 --adminurl=http://{{ public_ip }}:9292

keystone endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ identity / {print $2}') --publicurl=http://{{ public_ip }}:5000/v2.0 --internalurl=http://{{ public_ip }}:5000/v2.0 --adminurl=http://{{ public_ip }}:35357/v2.0

neutron endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ network / {print $2}') --publicurl=http://{{ public_ip }}:9696 --internalurl=http://{{ public_ip }}:9696 --adminurl=http://{{ public_ip }}:9696

nova endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ compute / {print $2}') --publicurl=http://{{ public_ip }}:8774/v2/$\(tenant_id\)s --internalurl=http://{{ public_ip }}:8774/v2/$\(tenant_id\)s --adminurl=http://{{ public_ip }}:8774/v2/$\(tenant_id\)s

cinder endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ volume / {print $2}') --publicurl=http://{{ public_ip }}:8776/v1/$\(tenant_id\)s --internalurl=http://{{ public_ip }}:8776/v1/$\(tenant_id\)s --adminurl=http://{{ public_ip }}:8776/v1/$\(tenant_id\)s

orchestration endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ orchestration / {print $2}') --publicurl=http://{{ public_ip }}:8004/v1/$\(tenant_id\)s --internalurl=http://{{ public_ip }}:8004/v1/$\(tenant_id\)s --adminurl=http://{{ public_ip }}:8004/v1/$\(tenant_id\)s

cloudformation endpoint:
  cmd.run:
    - env:
      - OS_USERNAME: 'admin'
      - OS_PASSWORD: {{ ospassword }}
      - OS_TENANT_NAME: 'admin'
      - OS_AUTH_URL: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_ENDPOINT: 'http://{{ public_ip }}:35357/v2.0'
      - OS_SERVICE_TOKEN: {{ ks_token }}
    - name: keystone --os-auth-url=http://127.0.1.1:5000/v2.0  --os-token {{ ks_token }} endpoint-create --service-id=$(keystone service-list | awk '/ cloudformation / {print $2}') --publicurl=http://{{ public_ip }}:8000/v1 --internalurl=http://{{ public_ip }}:8000/v1 --adminurl=http://{{ public_ip }}:8000/v1

