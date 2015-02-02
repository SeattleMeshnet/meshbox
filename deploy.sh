#!/bin/bash

set -ex

# Usage:
# 1. docker run -i -t lgierth/meshbox /sbin/init
# 2. printf "12345\n12345\n" | passwd
# 3. ifconfig eth0 | grep 'inet addr'
# 3. coding
# 4. build-scripts/deploy.sh root@ADDRESS 12345

# root files
sshpass -p $2 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r cjdns/files/* $1:/

# Lua files
sshpass -p $2 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r cjdns/lua/* $1:/usr/lib/lua/

# LuCI files
sshpass -p $2 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r luci-app-cjdns/luasrc/* $1:/usr/lib/lua/luci/

# Purge LuCI cache
sshpass -p $2 ssh \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  $1 'rm -r /tmp/luci-modulecache'
