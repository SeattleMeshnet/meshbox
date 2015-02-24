#!/usr/bin/env bash

set -ex

IF="eno1"
USER="admin"
PASSWORD="password"

[ -e telnetenable.py ] || wget https://raw.githubusercontent.com/insanid/netgear-telenetenable/master/telnetenable.py
sed -i 's/SOCK_DGRAM/SOCK_STREAM/' telnetenable.py

ip link set "$IF" up
ip addr add 192.168.1.2/30 dev "$IF" 2>/dev/null || true


while true; do
  ping -w 30 -c 1 192.168.1.1 >/dev/null
  mac="$( arp -n -i "$IF" | grep 192.168.1.1 | while read _ip _type mac _resgt; do
    echo $mac | tr -d ':' | tr '[:lower:]' '[:upper:]'
    break; done; )"
  [ "$mac" ]
  hw="$( curl -s -m 30 "http://$USER:$PASSWORD@192.168.1.1/RST_status.htm" |
    grep -A 1 "Hardware Version" | tail -n1 | cut -d'>' -f2 | cut -d'<' -f1 )"
  [ "$hw" = "wnr2000v3" ]
  # SOCK_STREAM used instead of SOCK_DGRAM

  python2 telnetenable.py 192.168.1.1 $mac Gearguy Geardog || true
  sleep 2;
  echo "socat time"
  t=$(mktemp)
  # make sure max size of image is 3473408, e.g. using stat -c '%s' $file
  # Todo: randomize MAC and serial using artmtd
  cat <<EOF >"$t"
TIMEOUT 5
"root@WNR2000v3:/#" "killall -KILL uhttpd inetd traffic_meter button_detecte detcable dnsmasq lld2d crond datalib syslogd hostapd miniupnpd ntpclient net-scan potval udhcpc ; echo \$TERM"
"vt102" "tftp -g -l /tmp/openwrt.bin -r openwrt-ar71xx-generic-wnr2000v3-squashfs-sysupgrade.bin 192.168.1.2"
"#" "md5sum /tmp/openwrt.bin"
"745be46c2f00aa10d97a2582f92af55d" "mtd unlock /dev/mtd/2"
"Unlock" "mtd -r -e mtd2 write /tmp/openwrt.bin mtd2"
"#" \c
EOF
  socat exec:"/usr/sbin/chat -e -f $t",pty,echo=0,cr tcp:192.168.1.1:23,crlf
  rm "$t"

  break
done
