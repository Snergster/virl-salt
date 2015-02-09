pip on the box:
  pkg.installed:
    - name: python-pip
    - refresh: True
    - unless: ls /usr/local/bin/pip
    
