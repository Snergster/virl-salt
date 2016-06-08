{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True)) %}
{% set domain_name = salt['pillar.get']('virl:domain_name', salt['grains.get']('domain_name', 'virl.info'))%}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'controller'))%}
{% set virl_cluster = salt['pillar.get']('virl:virl_cluster', salt['grains.get']('virl_cluster', False))%}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set compute1_hostname = salt['grains.get']('compute1_hostname', 'compute1')%}
{% set compute2_hostname = salt['grains.get']('compute1_hostname', 'compute2')%}
{% set compute3_hostname = salt['grains.get']('compute1_hostname', 'compute3')%}
{% set compute4_hostname = salt['grains.get']('compute1_hostname', 'compute4')%}

hostnames-for-cluster-block:
  file.blockreplace:
    - name: /etc/hosts
    - append_if_not_found: True
    - marker_start: '# VIRL cluster start block'
    - marker_end: '# VIRL cluster end block'
    - content: "{{controllerip}}  controller  controller.{{ domain_name }}\n"
    - show_changes: True
    - backup: '.bak'


{% if controller and virl_cluster %}
  {% if salt['grains.get']('compute1_active', true)%}
compute1 config block:
  file.accumulated:
    - filename: /etc/hosts
    - name: accumulater-compute
    - require_in:
      - file: hostnames-for-cluster-block
    - text: {{ salt['grains.get']('compute1_internalnet_ip', '172.16.10.251' )}} compute1 compute1.{{ domain_name }}
  {% endif %}

  {% if salt['grains.get']('compute2_active', true)%}
compute2 config block:
  file.accumulated:
    - filename: /etc/hosts
    - name: accumulater-compute
    - require_in:
      - file: hostnames-for-cluster-block
    - text: {{ salt['grains.get']('compute2_internalnet_ip', '172.16.10.252' )}} compute2 compute2.{{ domain_name }}
  {% endif %}

  {% if salt['grains.get']('compute3_active', true)%}
compute3 config block:
  file.accumulated:
    - filename: /etc/hosts
    - name: accumulater-compute
    - require_in:
      - file: hostnames-for-cluster-block
    - text: {{ salt['grains.get']('compute3_internalnet_ip', '172.16.10.253' )}} compute3 compute3.{{ domain_name }}
  {% endif %}

  {% if salt['grains.get']('compute4_active', true)%}
compute4 config block:
  file.accumulated:
    - filename: /etc/hosts
    - name: accumulater-compute
    - require_in:
      - file: hostnames-for-cluster-block
    - text: {{ salt['grains.get']('compute4_internalnet_ip', '172.16.10.254' )}} compute4 compute4.{{ domain_name }}
  {% endif %}
#

{% else %}

compute config block:
  file.accumulated:
    - filename: /etc/hosts
    - name: accumulater-compute
    - text: "{{ salt['pillar.get']('virl:internalnet_ip', salt['grains.get']('internalnet_ip', '172.16.10.250' ))}} {{hostname}} {{hostname}}.{{ domain_name}}"
    - require_in:
      - file: hostnames-for-cluster-block
{% endif %}
