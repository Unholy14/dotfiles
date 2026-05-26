#!/bin/bash
cava -p /home/sevro/.config/cava/eww.ini | while read line; do
    echo "$line"
done
