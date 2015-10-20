#! /bin/bash

### BEGIN INIT INFO
# Provides:          salt-id
# Required-Start:    
# Required-Stop:
# X-Start-Before:    virl-std
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: create a random salt-id
# Description: create a random salt-id
### END INIT INFO

. /lib/lsb/init-functions

N=/etc/init.d/salt-id

VIRL_INI="/etc/virl.ini"
#VIRL_INI="/home/virl/virl.ini"
MINION="/etc/salt/minion.d/extra.conf"
#MINION="/home/virl/extra.conf"
PREFIX="nag"

set -e

case "$1" in
  start)
	SALT_ID=$PREFIX$( printf "%05d" $(( $RANDOM * 10 % 100000 )) )
	/usr/bin/crudini --set $VIRL_INI DEFAULT salt_id $SALT_ID
	/usr/bin/crudini --set $MINION '' id \'$SALT_ID\'
	/usr/bin/salt-call --local grains.setval salt_id $SALT_ID
	;;
  stop|reload|restart|force-reload|status)
	;;
  *)
	echo "Usage: $N {start|stop|restart|force-reload|status}" >&2
	exit 1
	;;
esac

exit 0
