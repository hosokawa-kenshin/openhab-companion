#!/bin/bash

set -eu
source settings

cd "$(dirname "$0")"

if [ -z "$DB_FILE" ]; then
  DB_FILE="$(dirname "$0")/db/beacone.db"
fi

sqlite3 $DB_FILE "PRAGMA journal_mode=WAL;"

# Get a new ID
new_id=$(( $(sqlite3 $DB_FILE "SELECT MAX(ID) FROM Signal;") + 1 ))

# If the ID is not obtained, set 0
if [ -z "$new_id" ]; then
    new_id=0
    echo $new_id
fi

# Insert data into the Signal table
function insert_to_db() {
  sqlite3 $DB_FILE -cmd ".timeout 20000"<<EOF
INSERT INTO Signal (ID, BeaconUUID, MediatorUID, RSSI, Timestamp, Description)
VALUES ($1, '$2', '$3', $4, '$5', '$6');
EOF
}

# Receive data from MQTT and insert it into the database
function subscribe_from_mqtt() {
  mosquitto_sub -h "$MQTT_HOST" -t "$MQTT_SUB_TOPIC" -F "%I %t %p" | while read line; do
    timestamp=$(echo "$line" | cut -d ' ' -f1)
    mediator_uid=$(echo "$line" | cut -d ' ' -f2 | cut -d '/' -f7)
    json=$(echo "$line" | cut -d ' ' -f3-)

    beacon_uuid=$(echo "$json" | jq -r '.uuid')
    rssi=$(echo "$json" | jq -r '.rssi')
    tx_power=$(echo "$json" | jq -r '.txpower')

    insert_to_db $new_id $beacon_uuid $mediator_uid $rssi $timestamp ""
    new_id=$(( $new_id + 1 ))
  done
}

# Cleanup function to kill the subscribe_from_mqtt process
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

# Publish data to MQTT
function publish_to_mqtt() {
  local message="$1"
  mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_PUB_TOPIC" -m "$message"
}

# Fetch active member list from Google Spreadsheet and
# shows account and beacon minor id in TSV format.
#
# returns:
# nom	xxx
# hosokawa	xxx
# :

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
  local i=0

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

    local members_count=$(echo "$members" | wc -l)
    local sentinel=$(date --iso-8601=seconds)
    local json='['

    # Collect log
    sleep $INTERVAL

    last_log_time="$(sqlite3 $DB_FILE -cmd ".timeout 20000"<<EOF
SELECT Timestamp FROM Signal ORDER BY ID DESC LIMIT 1;
EOF
)"
    # If there is no new log, skip the process
    if [[ "$sentinel" < "$last_log_time" ]]; then
      isExistLog=1
    else
      isExistLog=0
    fi

    echo "$members" | while read account uuid
    do
      echo -n "$account: "
      # If specific beacon exists in collected log
      if [[ $isExistLog ]] ; then
        result=$(sqlite3 $DB_FILE -cmd ".timeout 20000"<<EOF
SELECT m.Room
FROM Signal s
JOIN Mediator m ON s.MediatorUID = m.UID
WHERE s.BeaconUUID = '$uuid'
  AND s.Timestamp >= '$sentinel'
  AND s.RSSI >= $THRESHOLD
ORDER BY s.RSSI DESC
LIMIT 1;
EOF
        )
        if [ -z "$result" ]; then
          status="absence"
        else
          status="$result"
        fi
      else
        status="absence"
      fi
      echo "$status"
      json=${json%']'}
      if [ $i -ne 0 ]; then
        json+=$(printf ',')
      fi
      i=$(( $i + 1 ))
      json+=$(printf '{name: "%s",location: "%s"}]' $account $status)
      if [ $i -eq $members_count ]; then
        publish_to_mqtt "$json"
      fi
    done
  done
}

main "$@"
