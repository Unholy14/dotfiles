#!/bin/bash
cava -p ~/.config/cava/eww.ini | while IFS=';' read -r -a vals; do
    out=""
    for v in "${vals[@]}"; do
        v=${v//[^0-9]/}
        [ -z "$v" ] && continue
        case $v in
            0) out="${out}▂" ;;
            1) out="${out}▄" ;;
            2) out="${out}▆" ;;
            3) out="${out}█" ;;
            *) out="${out}█" ;;
        esac
    done
    [ -n "$out" ] && echo "$out" > /tmp/cava_out
done

