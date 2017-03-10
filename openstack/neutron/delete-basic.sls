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


{% set neutron_auth = '--os-tenant-name admin --os-username admin --os-password ' + ospassword + ' --os-auth-url=http://' + controllerip + ':5000/' + kav %}
{% for each in ['flat','flat1','ext-net'] %}
  {% set subnet_id = salt['cmd.run'](cmd='neutron ' + neutron_auth + ' subnet-list --name=' + each + ' --column id --format value', env={'OS_PROJECT_DOMAIN_ID': 'default', 'OS_USER_DOMAIN_ID': 'default'} if virl.mitaka else {} ) %}
  {% if subnet_id %}
  
delete floating ips {{ each }}:
  cmd.run:
    - name: neutron {{ neutron_auth }} port-list --fixed_ips subnet_id={{ subnet_id }} --device_owner=network:floatingip --column device_id --format value | xargs -rn1 neutron {{ neutron_auth }} floatingip-delete
    {% if virl.mitaka %}
    - require:
      - environ: project_domain_env delete
      - environ: user_domain_env delete
    {% endif %}

clear router-gateway {{ each }}:
  cmd.run:
    - name: neutron {{ neutron_auth }} port-list --fixed_ips subnet_id={{ subnet_id }} --device_owner=network:router_gateway --column device_id --format value | xargs -rn1 neutron {{ neutron_auth }} router-gateway-clear
    {% if virl.mitaka %}
    - require:
      - environ: project_domain_env delete
      - environ: user_domain_env delete
    {% endif %}

delete ports {{ each }}:
  cmd.run:
    - name: neutron {{ neutron_auth }} port-list --fixed_ips subnet_id={{ subnet_id }} --column id --format value | xargs -rn1 neutron {{ neutron_auth }} port-delete
    {% if virl.mitaka %}
    - require:
      - environ: project_domain_env delete
      - environ: user_domain_env delete
      - delete floating ips {{ each }}
      - clear router-gateway {{ each }}
    {% endif %}

delete {{ each }}:
  cmd.run:
    - name: neutron {{ neutron_auth }} subnet-delete {{ each }}
    {% if virl.mitaka %}
    - require:
      - environ: project_domain_env delete
      - environ: user_domain_env delete
      - delete ports {{ each }}
    {% endif %}

  {% endif %}
{% endfor %}

