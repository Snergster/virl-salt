#!/bin/bash
MESSAGE=$1
CONFIG="room_id={{salt['pillar.get']('hipchat:roomid:special', salt['grains.get']('hipchat_roomid_special', '')) }}&from=Special&color=red"
/usr/bin/curl -d $CONFIG --data-urlencode "message=${MESSAGE}" 'https://api.hipchat.com/v1/rooms/message?auth_token={{salt['pillar.get']('hipchat:api_key', salt['grains.get']('hipchat_apikey', '')) }}&format=json'
