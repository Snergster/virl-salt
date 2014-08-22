salted:
  cmd.run:
    - cwd: /srv/salt
    - name: wget -r -l1 --timestamping --no-directories --no-parent -Avirl-install.py -A.sls http://wwwin-drrc.cisco.com/virl/download/.salt
