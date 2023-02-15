#!/bin/bash

set -eu

MQTT_HOST="mqtt.gc.cs.okayama-u.ac.jp"
MQTT_TOPIC="dt/pinot/v1/ou/eng4/room106/marine/attendance"

# You may have multiple BT interfaces on your system.
# To use a specific BT interface, set the BT_MACADDR.
# BT_MACADDR="00:1B:DC:05:7E:2A" # USB dongle
BT_MACADDR="DC:A6:32:6D:18:9F"   # Built-in Adapter

# find suitable bluetooth interface name from BT_MAC
# bt_mac_to_ifname "00:1B:DC:05:7E:2A"
# → hci0
function bt_mac_to_ifname() {
  local bt_mac="$1"
  hciconfig | grep -i -B 1 "$bt_mac" | head -1 | cut -d: -f1
}

# From BT_IFNAME, scan bluetooth device with BT_MAC_ADDR.
# echo "attendance" if found, echo "absence" if not.
#
# bt_scan_mac hci0 "xx:xx:xx:xx:xx:xx"
# → attendance
function bt_scan_mac() {
  local bt_ifname="$1"
  local bt_mac_addr="$2"
  local device_name=$(hcitool -i "$bt_ifname" name "$bt_mac_addr")

  if [ -n "$device_name" ]; then
    echo "attendance"
  else
    echo "absence"
  fi
}

function publish_to_mqtt() {
  local message="$1"
  mosquitto_pub -h "$MQTT_HOST" -t "$MQTT_TOPIC" -m "$message"
}

# Fetch active member list from Google Spreadsheet and
# shows account and btmac in TSV format.
#
# returns:
# nom	xx:xx:xx:xx:xx:xx
# ueno	xx:xx:xx:xx:xx:xx
# :
#
function update_nomlab_members() {
  sheetq show --format=json members \
    | jq -r '.[] | select(.title | test("[0-9]{4}[BMD]") | not) |
             [.account,.btmac] | @tsv'
}

echo "Starting $0"

# BT_IFNAME=$(bt_mac_to_ifname "$BT_MACADDR")
BT_IFNAME=hci0
echo "Use $BT_IFNAME"

UPDATED_MEMBERS_AT=""
while true
do
  TODAY=$(date +'%Y-%d-%m')

  if [ "$UPDATED_MEMBERS_AT" != "$TODAY" ]; then
    echo -n "Get member list from Google Spreadsheet..."
    MEMBERS=$(update_nomlab_members)
    echo "Done."
    UPDATED_MEMBERS_AT=$(date +'%Y-%d-%m')
  fi

  echo "$MEMBERS" | \
    while read ACCOUNT BTMAC
    do
      echo -n "$ACCOUNT: "
      ATTENDANCE=$(bt_scan_mac "$BT_IFNAME" "$BTMAC")
      echo "$ATTENDANCE"
      publish_to_mqtt $(printf '{"%s":"%s"}' "$ACCOUNT" "$ATTENDANCE")
    done
done
