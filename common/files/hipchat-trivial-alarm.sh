#!/bin/bash
MESSAGE=$1
CONFIG="room_id={{salt['pillar.get']('hipchat:roomid:trivial', salt['grains.get']('hipchat_roomid_trivial', '')) }}&from=Trivial&color=yellow"
/usr/bin/curl -d $CONFIG --data-urlencode "message=${MESSAGE}" 'https://api.hipchat.com/v1/rooms/message?auth_token={{salt['pillar.get']('hipchat:api_key', salt['grains.get']('hipchat_apikey', '')) }}&format=json'
