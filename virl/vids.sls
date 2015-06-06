
/var/local/video/cl_main.mp4:
  file.managed:
    - source: salt://images/private/cl_main.mp4
    - user: virl
    - group: virl
    - mode: 755

/var/local/video/cl_new.mp4:
  file.managed:
    - source: salt://images/private/cl_new.mp4
    - user: virl
    - group: virl
    - mode: 755
