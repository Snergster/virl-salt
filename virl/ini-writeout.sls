/etc/virl.ini:
  file.managed:
   - contents_pillar: virl
   - user: virl
   - group: virl
   - mode: 0755
