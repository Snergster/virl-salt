
{% from "virl.jinja" import virl with context %}

ank prereq pkgs:
  pkg.installed:
      - pkgs:
        - libxml2-dev
        - libxslt1-dev

{% if not virl.masterless %}

/var/cache/virl/ank files:
  file.recurse:
    - name: /var/cache/virl/ank
    - source: "salt://ank/{{ virl.venv }}/"
    - user: virl
    - group: virl
    - file_mode: 755

{% endif %}


ank prereq:
  pip.installed:
    {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
    {% endif %}
    - require:
      - pkg: ank prereq pkgs
    - names:
      - lxml >= 3.3.3
      - configobj >= 4.7.1
      - six >= 1.9.0
      - Mako >= 0.8.0
      - MarkupSafe >= 0.23
      - certifi >= 14.5.14
      - backports.ssl_match_hostname >= 3.4.0.2
      - netaddr == 0.7.15
      - networkx >= 1.7
      - PyYAML >= 3.10
      - pexpect == 3.1
      - pyparsing >= 2.0.1
      - tornado >= 4.3

textfsm:
  pip.installed:
    - name: textfsm >= 0.2.1
    - find_links: "file:///var/cache/virl/ank"
    - onlyif: ls /var/cache/virl/ank/textfsm*
    - no_deps: True
    - use_wheel: True
    - no_index: True

