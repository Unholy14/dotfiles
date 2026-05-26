#!/bin/bash

# --- 0. MEMORIA DEL SCRIPT ---
CACHE_FILE="$HOME/.config/current_theme.cache"
if [ -f "$CACHE_FILE" ]; then
    source "$CACHE_FILE"
else
    # Si no hay caché, asumimos que partimos del rojo original
    OLD_BG="#0a0a0a"; OLD_PRIMARY="#cc0000"; OLD_SECONDARY="#8b0000"
    OLD_ACCENT="#ff3333"; OLD_DARK_ACCENT="#330000"; OLD_HOVER="#660000"
fi

TEMA=$1

# --- 1. DEFINICIÓN DE TEMAS ---
if [ "$TEMA" == "psycho" ]; then
    BG="#0a0a0a"; PRIMARY="#cc0000"; SECONDARY="#8b0000"; ACCENT="#ff3333"; DARK_ACCENT="#330000"; HOVER="#660000"
    GTK_THEME_NAME="Skeuos-Red-Dark"
elif [ "$TEMA" == "matrix" ]; then
    BG="#050a05"; PRIMARY="#00cc00"; SECONDARY="#008800"; ACCENT="#33ff33"; DARK_ACCENT="#003300"; HOVER="#004400"
    GTK_THEME_NAME="Skeuos-Green-Dark"
elif [ "$TEMA" == "ocean" ]; then
    BG="#050a0f"; PRIMARY="#0066cc"; SECONDARY="#004488"; ACCENT="#3399ff"; DARK_ACCENT="#002244"; HOVER="#003366"
    GTK_THEME_NAME="Skeuos-Blue-Dark"
elif [ "$TEMA" == "amethyst" ]; then
    BG="#0a0510"; PRIMARY="#9d00ff"; SECONDARY="#5e0099"; ACCENT="#c766ff"; DARK_ACCENT="#2a004d"; HOVER="#440066"
    GTK_THEME_NAME="Skeuos-Violet-Dark"
elif [ "$TEMA" == "cyberpunk" ]; then
    BG="#0a0a05"; PRIMARY="#fcee0a"; SECONDARY="#b3a700"; ACCENT="#ffff5c"; DARK_ACCENT="#4d4700"; HOVER="#666000"
    GTK_THEME_NAME="Skeuos-Yellow-Dark"
elif [ "$TEMA" == "ghost" ]; then
    BG="#080808"; PRIMARY="#cccccc"; SECONDARY="#888888"; ACCENT="#ffffff"; DARK_ACCENT="#333333"; HOVER="#444444"
    GTK_THEME_NAME="Skeuos-Grey-Dark"
else
    echo "Uso: ./cambiar_tema.sh [psycho|matrix|ocean|amethyst|cyberpunk|ghost]"
    exit 1
fi

echo "Inyectando colores para el tema: $TEMA..."

# --- 2. HYPRLAND ---
cat <<EOF > ~/.config/hypr/colors.conf
\$color_bg = rgba(${BG:1}ff)
\$color_primary = rgba(${PRIMARY:1}ff)
\$color_secondary = rgba(${SECONDARY:1}ff)
EOF

# --- 3. KITTY ---
cat <<EOF > ~/.config/kitty/theme.conf
background $BG
foreground $PRIMARY
selection_background $PRIMARY
selection_foreground $BG
cursor $PRIMARY
cursor_text_color $BG
color0  $BG
color1  $PRIMARY
color2  $SECONDARY
color3  $ACCENT
color4  $HOVER
color5  $SECONDARY
color6  $ACCENT
color7  $PRIMARY
color8  $DARK_ACCENT
color15 #ffffff
EOF

# --- 4. QUICKSHELL ---
QML_DIR="$HOME/.config/quickshell"
if [ -d "$QML_DIR" ]; then
    find "$QML_DIR" -type f -name "*.qml" -exec sed -i \
        -e "s/$OLD_BG/$BG/g" -e "s/$OLD_PRIMARY/$PRIMARY/g" \
        -e "s/$OLD_SECONDARY/$SECONDARY/g" -e "s/$OLD_ACCENT/$ACCENT/g" \
        -e "s/$OLD_DARK_ACCENT/$DARK_ACCENT/g" -e "s/$OLD_HOVER/$HOVER/g" {} +
fi

LOGO_ORIGEN="$HOME/.config/quickshell/logos/logo_${TEMA}.png"
LOGO_DESTINO="$HOME/.config/quickshell/logo.png"
if [ -f "$LOGO_ORIGEN" ]; then
    cp "$LOGO_ORIGEN" "$LOGO_DESTINO"
fi

# --- 5. GTK / THUNAR ---
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-application-prefer-dark-theme=1
EOF
cat <<EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-application-prefer-dark-theme=1
EOF

# --- 6. SPOTIFY PLAYER ---
cat <<EOF > ~/.config/spotify-player/theme.toml
[[themes]]
name = "dynamic"
[themes.palette]
background = "$BG"
foreground = "#FFFFFF"
[themes.component_style]
block_title = { fg = "$PRIMARY", modifiers = ["Bold"] }
playback_track = { fg = "$PRIMARY", modifiers = ["Bold"] }
playback_artists = { fg = "#FFFFFF" }
playback_album = { fg = "$SECONDARY" }
playback_progress_bar = { bg = "$BG", fg = "$PRIMARY" }
playback_progress_bar_unfilled = { bg = "$BG", fg = "$DARK_ACCENT" }
track = { fg = "#FFFFFF" }
slider = { bg = "$BG", fg = "$PRIMARY" }
borders = { fg = "$DARK_ACCENT" }
EOF

# --- 7. CAVA ---
CAVA_SCRIPT="$HOME/.config/hypr/scripts/cava.sh"
if [ -f "$CAVA_SCRIPT" ]; then
    sed -i -E "s/foreground=#[0-9a-fA-F]{6}/foreground=$PRIMARY/g" "$CAVA_SCRIPT"
fi

# --- 8. ROFI ---
ROFI_DIR="$HOME/.config/rofi"
if [ -d "$ROFI_DIR" ]; then
    find "$ROFI_DIR" -type f -name "*.rasi" -exec sed -i \
        -e "s/$OLD_BG/$BG/g" -e "s/$OLD_PRIMARY/$PRIMARY/g" \
        -e "s/$OLD_SECONDARY/$SECONDARY/g" -e "s/$OLD_ACCENT/$ACCENT/g" \
        -e "s/$OLD_DARK_ACCENT/$DARK_ACCENT/g" -e "s/$OLD_HOVER/$HOVER/g" {} +
fi

# --- 9. DUNST (NOTIFICACIONES) ---
DUNST_CONF="$HOME/.config/dunst/dunstrc"
if [ -f "$DUNST_CONF" ]; then
    sed -i \
        -e "s/$OLD_BG/$BG/g" -e "s/$OLD_PRIMARY/$PRIMARY/g" \
        -e "s/$OLD_SECONDARY/$SECONDARY/g" -e "s/$OLD_ACCENT/$ACCENT/g" \
        -e "s/$OLD_DARK_ACCENT/$DARK_ACCENT/g" -e "s/$OLD_HOVER/$HOVER/g" "$DUNST_CONF"
fi

# --- 10. GUARDAR CACHÉ ---
cat <<EOF > "$CACHE_FILE"
OLD_BG="$BG"
OLD_PRIMARY="$PRIMARY"
OLD_SECONDARY="$SECONDARY"
OLD_ACCENT="$ACCENT"
OLD_DARK_ACCENT="$DARK_ACCENT"
OLD_HOVER="$HOVER"
EOF

# --- 11. RECARGAR SISTEMA ---
hyprctl reload
killall -USR1 kitty
killall quickshell
killall thunar
killall dunst

# Reiniciamos los demonios necesarios
dunst & disown
hyprctl dispatch exec quickshell

echo "¡Transformación total del sistema completada con éxito!"
