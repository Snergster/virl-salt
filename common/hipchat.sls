/usr/local/bin/hipchat-major-alarm:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://common/files/hipchat-major-alarm.sh"
