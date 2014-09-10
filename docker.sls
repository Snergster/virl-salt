
/etc/apt/sources.list.d/docker.list:
  file.managed:
    - source: salt://files/docker.list
  cmd.wait:
    - name: apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - cwd: /tmp
    - watch:
      - file: /etc/apt/sources.list.d/docker.list

lxc-docker:
  pkg.installed:
    - refresh: true
    - require:
      - file: /etc/apt/sources.list.d/docker.list

conntrack:
  pkg.installed:
    - refresh: false

ethtool:
  pkg.installed:
    - refresh: false

/usr/local/bin/weave:
  file.managed:
    - source: https://raw.githubusercontent.com/zettio/weave/master/weaver/weave
    - mode: 0755

