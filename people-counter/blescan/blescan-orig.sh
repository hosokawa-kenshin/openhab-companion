#!/bin/bash
set -eu

MQTT_URL="mqtt.gc.cs.okayama-u.ac.jp"
TOPIC="dt/pinot/v1/ou/eng4/room106/marine/attendance"
BT_MACADDR="00:1B:DC:05:7E:2A"

echo "Starting blescan.sh"
TODAY=$(date | awk '{print $2}')
MEMBERS=$(sheetq show members | tail -n +2 | grep -E -v [0-9]\{4\}[BMD] | awk '{print $6" "$13}')
echo "Get members information from Google Spreadsheet"

function bt_mac_to_ifname()
{
    local bt_mac="$1"

    hciconfig |grep -i -B 1 "$bt_mac" |head -1 |cut -d: -f1
}

IFNAME=$(bt_mac_to_ifname "$BT_MACADDR")
echo "Use $IFNAME"

while true; do
    NEW_DATE=$(date | awk '{print $2}')
    if [ $NEW_DATE = $TODAY ]; then
        true
    else
        #from google spred sheet
        MEMBERS=$(sheetq show members | tail -n +2 | grep -E -v [0-9]\{4\}[BMD] | awk '{print $6" "$13}')
	echo "Update members information from Google Spreadsheet"
        TODAY=$NEW_DATE
    fi

    echo "$MEMBERS" | \
    while read NAME ADDR
    do
	#DNAME=$(hcitool -i ${IFNAME} name ${ADDR})
        DNAME=$(hcitool -i hci0 name ${ADDR})	
        if [ "$DNAME" = "" ] ; then
            MSG="{\"${NAME}\":\"absence\"}"
        else
            MSG="{\"${NAME}\":\"attendance\"}"
        fi
        mosquitto_pub -h "$MQTT_URL" -t "$TOPIC" -m "$MSG"
    done
done
