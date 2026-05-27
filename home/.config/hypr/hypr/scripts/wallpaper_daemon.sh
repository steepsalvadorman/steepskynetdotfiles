#!/bin/bash
sleep 5
~/.config/hypr/scripts/wallhaven.sh &

while true; do
    sleep 1800
    ~/.config/hypr/scripts/wallhaven.sh &
done
