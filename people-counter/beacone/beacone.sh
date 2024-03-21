#!/bin/bash

set -eu
source settings

cd "$(dirname "$0")"

if [ -z "$LOG_FILE" ]; then
  LOG_FILE="$(dirname "$0")/beacon.log"
fi

function cleanup() {
  echo "Cleaning up..."
  # Kill the subscribe_from_mqtt process
  if [ -n "${SUBSCRIBE_PID-}" ]; then
    kill "$SUBSCRIBE_PID"
    wait "$SUBSCRIBE_PID" 2>/dev/null
  fi
}

# Set trap to call cleanup function on script exit
trap cleanup EXIT

function publish_to_mqtt() {
  local message="$1"
  mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PUB_TOPIC" -m "$message"
}

function subscribe_from_mqtt() {
  mosquitto_sub -h "$MQTT_HOST" -t "$MQTT_SUB_TOPIC" -F "%I %t %p" >> $LOG_FILE
}
# Fetch active member list from Google Spreadsheet and
# shows account and beacon minor id in TSV format.
#
# returns:
# nom	xxx
# ueno	xxx
# :
#

function search_max_rssi_room() {
  local max_rssi=-999
  local max_line=""
  local lines="$1"
  
  while IFS= read -r line; do
    rssi=$(echo "$line" | awk '{print $3}' | jq -r '.rssi')
    room=$(echo "$line" | grep -oE 'room[0-9]+')
    if [[ "$rssi" -gt "$max_rssi" ]]; then
      max_rssi=$rssi
      max_room="$room"
    fi
  done <<< "$lines"

  echo "$max_room"
}

function update_nomlab_members() {
  sheetq show --format=json members \
    | jq -r '.[] | select(.title | test("[0-9]{4}[BMD]") | not) |
             [.account,.uuid] | @tsv'
}

function main() {
  local updated_members_at=""
  local members=""
  local status=""
  local result=""

  subscribe_from_mqtt &
  SUBSCRIBE_PID=$!

  while true
  do
    # If menber list is old
    local today=$(date +'%Y-%d-%m')
    if [ "$updated_members_at" != "$today" ]; then
      echo -n "Get member list from Google Spreadsheet..."
      members="$(update_nomlab_members)"
      echo "Done."
      updated_members_at=$(date +'%Y-%d-%m')
    fi

    local sentinel=$(date --iso-8601=seconds)
    # Collect log
    sleep $INTERVAL

    echo "$members" | \
      while read account uuid
      do
        echo -n "$account: "
        # If specific bminor exits in collected log
        if result=$(echo "$(cat "$LOG_FILE"; echo "$sentinel")" | sort -k 1 | sed -e "1,/^$sentinel/ d" | grep "$uuid") ; then 
          status=$(search_max_rssi_room "$result")
        else
          status="absence"
        fi
        echo "$status"
        publish_to_mqtt $(printf '{"%s":"%s"}' "$account" "$status")
      done
  done
}

main "$@"
