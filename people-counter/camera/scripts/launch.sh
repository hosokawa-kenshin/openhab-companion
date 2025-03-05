#!/bin/bash
set -e

function usage() {
    cat << EOT
launch.sh
    Launch people-counter program without any display
Usage
    launch.sh [SOURCE_URL] [MQTT_SERVER] [MQTT_SERVER] [MQTT_TOPIC]
EOT
}

if [ -z "$4" ]; then
    usage
    exit 1
fi

for i in $(seq 10 100); do
    DISPLAY_ALT=":$i"
    if [ "$DISPLAY_ALT" != "$DISPLAY" ]; then
        break
    fi
done
export DISPLAY=$DISPLAY_ALT

cd "$(dirname "$0")"
Xvfb -ac $DISPLAY -screen 0 1980x1080x24 &
python3 ../camera_people-counter.py --source "$1" --mqtt-server "$2" --mqtt-port "$3" --mqtt-topic "$4"

