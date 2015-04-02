#!/usr/bin/env bash

set -ex

# Dependencies:
# - Netgear WNR2000v3 with factory firmware, reachable via $INTERFACE
# - telnetenable.py - https://raw.githubusercontent.com/semyazza/netgear-telenetenable/9789182fe02f5ea9ce706cb3a15463a6f23b6064/telnetenable.py
# - TFTP server on $TFTP serving $IMAGE, e.g. atftpd

# TODO: make sure max size of image is 3473408 (see /proc/mtd rootfs),
#       e.g. using stat -c '%s' $IMAGE
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
IMAGE="openwrt-ar71xx-generic-wnr2000v3-squashfs-sysupgrade-vanilla.bin"
IMAGE_MD5="328e838a740fe24100b509ed3803e61e"
SECOND_IMAGE="openwrt-ar71xx-generic-wnr2000v3-squashfs-sysupgrade.bin"

# wait for the device to come up
ping -w 30 -c 1 $IP

# find out the device's mac address
mac=$(arp -n -i "$INTERFACE" | grep $IP | while read _ip _type mac _rest; do
  echo $mac | tr -d ':' | tr '[:lower:]' '[:upper:]'; break; done)
[ "$mac" ]

# enable the telnet console
ls -la telnetenable.py
python2 telnetenable.py $IP $mac Gearguy Geardog || true
sleep 1

# if the login banner says KAMIKAZE, it's the factory firmware
( echo open 192.168.1.1 ; sleep 1 ) | telnet 2>&1 | grep -v 'KAMIKAZE' ||
  # fetch openwrt image, and write it to the rootfs partition
  (
    echo open $IP
    sleep 1
    echo cat /proc/mtd
    sleep 1
    echo tftp -g -l /tmp/openwrt.bin -r $IMAGE $TFTP
    sleep 10
    echo "md5=\$(md5sum /tmp/openwrt.bin | cut -d' ' -f1)"
    sleep 2
    echo "killall -KILL uhttpd inetd traffic_meter button_detecte detcable dnsmasq lld2d crond datalib syslogd hostapd miniupnpd ntpclient net-scan potval udhcpc"
    sleep 1
    echo mtd unlock /dev/mtd/2
    sleep 1
    echo "[[ \"\$md5\" = \"$IMAGE_MD5\" ]] && mtd -r -e mtd2 write /tmp/openwrt.bin mtd2"
    sleep 60
    ping -w 60 -c 1 $IP
  ) | telnet

(
  echo open $IP
  sleep 1
  echo 'printf "12345\n12345" | passwd'
  sleep 1
) | telnet || true

ssh="sshpass -p 12345 ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=10 root@$IP"
sshWithRetry() {
  $ssh "$1" || (sleep 30 ; $ssh "$1")
}

scp="sshpass -p 12345 scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
$scp tftpboot/$SECOND_IMAGE root@$IP:/tmp/openwrt.bin
sshWithRetry "echo up"
$ssh 'sysupgrade -n /tmp/openwrt.bin || true' | grep 'Upgrade completed'

# give telnet a bit of time to come up
ping -w 30 -c 5 $IP

(
  echo open $IP
  sleep 1
  echo 'printf "12345\n12345" | passwd'
  sleep 1
) | telnet || true

sshWithRetry "echo up"
$ssh cjdrouteconf get
