#!/bin/bash

# Usage:
# 1. docker run -i -t lgierth/meshbox /sbin/init
# 2. set root password
# 3. ifconfig eth0 | grep 'inet addr'
# 3. coding
# 4. build-scripts/deploy.sh root@ADDRESS THEPASSWORD

# # contrib/lua
# sshpass -p 12345 scp \
#   -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
#   -r ../cjdns/contrib/lua/cjdns/* $0:/usr/lib/lua/cjdns/

# root files
sshpass -p 12345 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r cjdns/files/* $1:/

# Lua files
sshpass -p 12345 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r cjdns/lua/* $1:/usr/lib/lua/

# LuCI files
sshpass -p 12345 scp \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -r luci-cjdns/luasrc/* $1:/usr/lib/lua/luci/

# Purge LuCI cache
sshpass -p 12345 ssh \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  $1 'rm -r /tmp/luci-modulecache'
