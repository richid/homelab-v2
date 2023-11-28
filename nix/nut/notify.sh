#!/bin/bash

echo "$(date)" >> /tmp/nut.log

TITLE="${NOTIFYTYPE:-$1}"
MESSAGE="$1"
PRIORITY=5
TOKEN="Af7o6AqZ4HWZmB6"
URL="https://gotify.schu/message?token=${TOKEN}"

curl \
  -k \
  -s -S \
  -H 'Content-Type: application/json' \
  --data '{"message": "'"${MESSAGE}"'", "title": "'"${TITLE}"'", "priority":'"${PRIORITY}"', "extras": {"client::display": {"contentType": "text/markdown"}}}' \
  "$URL"
