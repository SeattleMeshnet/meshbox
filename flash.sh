#!/usr/bin/env bash

set -ex

# Dependencies:
# - Netgear WNR2000v3 with factory firmware, reachable via $INTERFACE
# - telnetenable.py - https://raw.githubusercontent.com/semyazza/netgear-telenetenable/9789182fe02f5ea9ce706cb3a15463a6f23b6064/telnetenable.py
# - TFTP server on $TFTP serving $IMAGE, e.g. atftpd

# TODO: make sure max size of image is 3473408, e.g. using stat -c '%s' $IMAGE
# TODO: set root password to unlock SSH
# TODO: test peering
# TODO: randomize MAC and serial using artmtd
# TODO: test automatic update
# TODO: test rollover of update signatures
# TODO: test factory reset (wrt cjdns identity)

INTERFACE="eth0"
IP="192.168.1.1"
USER="admin"
PASSWORD="password"
TFTP="192.168.1.2"
IMAGE="openwrt-ar71xx-generic-wnr2000v3-squashfs-sysupgrade.bin"
IMAGE_MD5="a4bd02a12b458cb6a7a8401995ae1c3dd"

# wait for the device to come up
ping -w 30 -c 1 -I $INTERFACE $IP

# make sure it's a compatible device
hw=$(curl -s -m 30 "http://$USER:$PASSWORD@$IP/RST_status.htm" |
  grep -A 1 "Hardware Version" | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1 )
[ "$hw" = "wnr2000v3" ]

# find out the device's mac address
mac=$(arp -n -i "$INTERFACE" | grep $IP | while read _ip _type mac _rest; do
  echo $mac | tr -d ':' | tr '[:lower:]' '[:upper:]'; break; done)
[ "$mac" ]

# enable the telnet console
ls -la telnetenable.py
python2 telnetenable.py $IP $mac Gearguy Geardog || true
sleep 1

# fetch openwrt image, and write it to the rootfs partition
(
  echo open 192.168.1.1
  sleep 1
  echo tftp -g -l /tmp/openwrt.bin -r $IMAGE $TFTP
  sleep 10
  echo "md5=\$(md5sum /tmp/openwrt.bin | cut -d' ' -f1)"
  sleep 1
  echo mtd unlock /dev/mtd/2
  sleep 1
  # echo "[[ \"\$md5\" = \"$IMAGE_MD5\" ]] && mtd -r -e mtd2 write /tmp/openwrt.bin mtd2"
  sleep 30
) | telnet
