{% from "virl.jinja" import virl with context %}

{% if virl.controller %}
{% if virl.mitaka %}

{% for agent in salt['neutron.list_agents']('virl')['agents'] %}
  {% if agent['admin_state_up'] == True and agent['host'] != virl.hostname %}
{{ agent['host']}} {{ agent['binary'] }} disable:
  cmd.run:
    - names:
      - neutron --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} agent-update --admin-state-down {{ agent['id'] }}
  {% endif %}

  {% if agent['binary'] in ['neutron-linuxbridge-agent'] or (agent['host'] == virl.hostname) %}
    {% if (virl.compute1_active and agent['host'] == virl.compute1_hostname) or
          (virl.compute2_active and agent['host'] == virl.compute2_hostname) or
          (virl.compute3_active and agent['host'] == virl.compute3_hostname) or
          (virl.compute4_active and agent['host'] == virl.compute4_hostname) %}
{{ agent['host']}} {{ agent['binary'] }} enable:
  cmd.run:
    - names:
      - neutron --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} agent-update --admin-state-up {{ agent['id'] }}
    {% endif %}
  {% endif %}
{% endfor %}


# TODO not applying 2 3
#                  compute2.virl.info:
#                      Minion did not return. [No response]

compute1:
  cmd.run:
    - names:
{% if virl.compute1_active %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-enable {{ virl.compute1_hostname }} nova-compute
{% else %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-disable {{ virl.compute1_hostname }} nova-compute
{% endif %}

compute2:
  cmd.run:
    - names:
{% if virl.compute2_active %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-enable {{ virl.compute2_hostname }} nova-compute
{% else %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-disable {{ virl.compute2_hostname }} nova-compute
{% endif %}

compute3:
  cmd.run:
    - names:
{% if virl.compute3_active %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-enable {{ virl.compute3_hostname }} nova-compute
{% else %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-disable {{ virl.compute3_hostname }} nova-compute
{% endif %}

compute4:
  cmd.run:
    - names:
{% if virl.compute4_active %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-enable {{ virl.compute4_hostname }} nova-compute
{% else %}
      - nova --os-user-domain-id=default --os-project-domain-id=default --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} service-disable {{ virl.compute4_hostname }} nova-compute
{% endif %}


compute1 apply:
  cmd.run:
{% if virl.compute1_active %}
    - name: salt {{ virl.compute1_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-enable
{% else %}
    - name: salt {{ virl.compute1_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-disable
{% endif %}

compute2 apply:
  cmd.run:
{% if virl.compute2_active %}
    - name: salt {{ virl.compute2_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-enable
{% else %}
    - name: salt {{ virl.compute2_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-disable
{% endif %}

compute3 apply:
  cmd.run:
{% if virl.compute3_active %}
    - name: salt {{ virl.compute3_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-enable
{% else %}
    - name: salt {{ virl.compute3_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-disable
{% endif %}

compute4 apply:
  cmd.run:
{% if virl.compute4_active %}
    - name: salt {{ virl.compute4_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-enable
{% else %}
    - name: salt {{ virl.compute4_hostname }}.{{ virl.domain_name }} state.sls common.salt-master.cluster-compute-disable
{% endif %}

{% endif %}
{% endif %}
