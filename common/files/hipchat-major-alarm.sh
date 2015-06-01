#!/bin/bash

#MESSAGE="Some crazy unescaped message with <a href=\"http://somewhere.com\">links</a> & stuff! Maybe even variables or commit messages: ${COMMIT_MESSAGE}"
MESSAGE=$1
CONFIG="room_id={{salt['pillar.get']('hipchat:roomid:major', salt['grains.get']('hipchat_roomid_major', '')) }}&from=Major&color=red"
/usr/bin/curl -d $CONFIG --data-urlencode "message=${MESSAGE}" 'https://api.hipchat.com/v1/rooms/message?auth_token={{salt['pillar.get']('hipchat:api_key', salt['grains.get']('hipchat_apikey', '')) }}&format=json'
