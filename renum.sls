{% set proxy = salt['grains.get']('proxy', False) %}
{% set cml = salt['grains.get']('cml', False) %}
{% set password = salt['grains.get']('password', 'password') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'password') %}
{% set stdport = salt['grains.get']('virl_webservices', '19399') %}
{% set uwmport = salt['grains.get']('virl_user_management', '19400') %}
{% set uwmpass = salt['grains.get']('uwmadmin_password', 'password') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set httpproxy = salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}

VIRL variable reset:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_openstack_password {{ password }}
      - crudini --set /etc/virl/virl.cfg env virl_openstack_service_token {{ keystone_service_token }}
      - crudini --set /etc/virl/virl.cfg env virl_std_port {{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_std_url http://localhost:{{ stdport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_port {{ uwmport }}
      - crudini --set /etc/virl/virl.cfg env virl_uwm_url http://localhost:{{ uwmport }}

variable reset std:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - cmd: VIRL variable reset

variable reset uwm:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - cmd: VIRL variable reset
