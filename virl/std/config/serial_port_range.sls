{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range', salt['grains.get']('start_of_serial_port_range', '17000')) %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range', salt['grains.get']('end_of_serial_port_range', '18000')) %}

include:
  - virl.std.config.uwm_restart
  - virl.std.config.std_restart

std nova-compute serial:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'serial_console'
    - parameter: 'port_range'
    - value: '{{ serstart }}:{{ serend }}'


