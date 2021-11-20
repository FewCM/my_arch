#!/bin/bash

Xephyr :3 -ac -screen 1780x980 &
XEPHYR_PID=$!
sleep 0.5

DISPLAY=:3 dwm
kill ${XEPHYR_PID}
