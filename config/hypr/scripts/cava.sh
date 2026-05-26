#!/bin/bash
kitty --class cava-widget \
  -o initial_window_width=1200 \
  -o initial_window_height=200 \
  -o background_opacity=0.0 \
  -o hide_window_decorations=yes \
  -o foreground=#cccccc \
  -- cava -p ~/.config/cava/config

