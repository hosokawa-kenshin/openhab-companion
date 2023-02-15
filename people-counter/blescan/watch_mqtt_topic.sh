#!/bin/bash

mosquitto_sub -v -h mqtt.gc.cs.okayama-u.ac.jp -p 1883 -t "dt/pinot/v1/ou/eng4/room106/marine/attendance"
