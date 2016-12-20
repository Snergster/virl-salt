{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set keystone_auth_version = salt['pillar.get']('virl:keystone_auth_version', salt['grains.get']('keystone_auth_version', 'v2.0')) %}
{% set kav = salt['pillar.get']('virl:keystone_auth_version', salt['grains.get']('keystone_auth_version', 'v2.0')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% from "virl.jinja" import virl with context %}

{% if virl.mitaka %}

project_domain_env delete:
  environ.setenv:
    - name: OS_PROJECT_DOMAIN_ID
    - value: default

user_domain_env delete:
  environ.setenv:
    - name: OS_USER_DOMAIN_ID
    - value: default

{% endif %}

update device owner:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-update --device-id None --device-owner None $1
{% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
{% endif %}

# delete ports
delete ports:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-delete $1
{% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
{% endif %}

delete ports check:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} port-delete $1
    - onfail:
      - cmd: delete ports
{% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
{% endif %}

# delete floating ips
delete floating ips:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} floatingip-list --format csv --column id | sed 1d | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} floatingip-delete $1
{% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
{% endif %}

clear ext-net router-gateway:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} router-list -c id -f csv | grep -o '[a-fA-F0-9-]\{36\}' | xargs -rn1 neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} router-gateway-clear
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} subnet-show ext-net
{% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
{% endif %}

{% for each in ['flat','flat1','ext-net'] %}
delete {{ each }}:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} subnet-delete {{ each }}
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ kav }} subnet-show {{ each }}
  {% if virl.mitaka %}
    - require:
      - environ: project_domain_env create
      - environ: user_domain_env create
  {% endif %}

{% endfor %}
