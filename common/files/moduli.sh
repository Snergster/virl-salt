#!/bin/bash
/usr/bin/awk '$5 > 2000' /etc/ssh/moduli > /tmp/moduli
mv -f /tmp/moduli /etc/ssh/moduli
rm -f /etc/ssh/ssh_host_*key*
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N "" < /dev/null
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -q -N "" < /dev/null
