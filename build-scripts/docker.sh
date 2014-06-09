#!/bin/bash

set -ex

cid=$(docker run -d lgierth/cjdns-openwrt /sbin/init)
pid=$(docker inspect -f '{{.State.Pid}}' $cid)
ipv4=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $cid)

sleep 7

ssh="sshpass -p 12345 ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ipv4"
# $ssh 'cjdroute --genconf | cjdroute --cleanconf | cjdrouteconf set'
$ssh 'mkdir /dev/net && ln -s /dev/tun /dev/net/tun'

ipv6=$($ssh 'uci get cjdns.cjdns.ipv6')

sudo mkdir /var/run/netns || true
sudo ln -s /proc/$pid/ns/net /var/run/netns/$pid

sudo ip tuntap add mode tun
ifname=$(ip link | tail -n2 | cut -d":" -f2 | head -n1 | cut -d" " -f2)

sudo ip link set $ifname netns $pid
sudo ip netns exec $pid ip addr add $ipv6/8 dev $ifname
sudo ip netns exec $pid ip link set mtu 1312 dev $ifname
sudo ip netns exec $pid ip link set $ifname up

$ssh 'section=$(uci add cjdns eth_interface) \
      && uci set cjdns.$section.bind=eth0 \
      && uci set cjdns.$section.beacon=2 \
      && uci set cjdns.cjdns.tun_device='$ifname' \
      && uci changes && uci commit'

$ssh '/etc/init.d/cjdns restart'
$ssh || true

$ssh '/etc/init.d/cjdns stop'
sudo ip netns exec $pid ip tuntap del mode tun $ifname || true
docker kill $cid || true
