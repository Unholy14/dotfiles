#!/bin/bash
URL=$(playerctl metadata mpris:artUrl 2>/dev/null)
if [[ $URL == https* ]]; then
    curl -s "$URL" -o /tmp/cover.jpg 2>/dev/null
    echo "/tmp/cover.jpg"
elif [[ $URL == file* ]]; then
    echo "${URL/file:\/\//}"
else
    echo "/home/sevro/Pictures/wallpapers/stanczyk.jpg"
fi
