/usr/local/bin/hipchat-major-alarm:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://common/files/hipchat-major-alarm.sh"

/usr/local/bin/hipchat-minor-alarm:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://common/files/hipchat-minor-alarm.sh"

/usr/local/bin/hipchat-trivial-alarm:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://common/files/hipchat-trivial-alarm.sh"

/usr/local/bin/hipchat-special-alarm:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://common/files/hipchat-special-alarm.sh"


