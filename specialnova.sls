mypackage:
   cmd.run: 
     - names: dpkg -i /tmp/mypackage.deb
     - require:
       - file: /tmp/mypackage.deb


/tmp/mypackage.deb:
   file.managed:
      - source: salt://mypackage.deb
