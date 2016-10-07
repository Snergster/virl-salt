{% set download_proxy = salt['pillar.get']('virl:download_proxy', salt['grains.get']('download_proxy', '')) %}
{% set download_no_proxy = salt['pillar.get']('virl:download_no_proxy', salt['grains.get']('download_no_proxy', '')) %}
{% set download_proxy_user = salt['pillar.get']('virl:download_proxy_user', salt['grains.get']('download_proxy_user', '')) %}

include:
  - virl.std.config.std_restart
  - virl.std.config.uwm_restart

set_config:
  cmd.run:
    - names:
      - crudini --set /etc/virl/common.cfg host download_proxy {{ download_proxy }}
      - crudini --set /etc/virl/common.cfg host download_no_proxy {{ download_no_proxy }}
      - crudini --set /etc/virl/common.cfg host download_proxy_user {{ download_proxy_user }}
      - crudini --set /etc/virl/virl-core.ini host download_proxy {{ download_proxy }}
      - crudini --set /etc/virl/virl-core.ini host download_no_proxy {{ download_no_proxy }}
      - crudini --set /etc/virl/virl-core.ini host download_proxy_user {{ download_proxy_user }}

