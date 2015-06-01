#!/bin/bash
#placeholder for minor alarm hipchat message
MESSAGE=$1
CONFIG="room_id={{salt['pillar.get']('hipchat:roomid:minor', salt['grains.get']('hipchat_roomid_minor', '')) }}&from=Minor&color=yellow"
/usr/bin/curl -d $CONFIG --data-urlencode "message=${MESSAGE}" 'https://api.hipchat.com/v1/rooms/message?auth_token={{salt['pillar.get']('hipchat:api_key', salt['grains.get']('hipchat_apikey', '')) }}&format=json'
