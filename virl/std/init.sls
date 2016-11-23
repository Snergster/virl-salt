{% from "virl.jinja" import virl with context %}

include:
  - .prereq
  - .clients
  - common.ifb
  - virl.std.tap-counter
  - .install
