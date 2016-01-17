#!/usr/bin/env bash

. /venv/bin/activate
[[ -z /buildbot/buildbot.tac ]] && buildbot create-master /buildbot
buildbot upgrade-master /buildbot
exec buildbot start --nodaemon /buildbot
