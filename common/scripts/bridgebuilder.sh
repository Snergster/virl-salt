#!/bin/bash
mkdir /tmp/bridge
cd /tmp/bridge/
if [ -z $version ]; then
    version=`uname -r`
fi
apt-get install -y linux-headers-$version
apt-get source -y linux-image-$version
cd linux*/
sed -i -e '/BR_GROUPFWD_RESTRICTED/s/4007/0000/' net/bridge/br_private.h
sed -i -e '/BR_GROUPFWD_RESTRICTED/s/0007/0000/' net/bridge/br_private.h
cp /usr/src/linux-headers-$version/Module.symvers .
make olddefconfig
make prepare modules_prepare
make SUBDIRS=scripts/mod
make SUBDIRS=net/bridge modules
cp -f net/bridge/bridge.ko /lib/modules/$version/kernel/net/bridge/
cp -f net/bridge/bridge.ko /tmp/bridge.ko-$version
rm -rf /tmp/bridge/
