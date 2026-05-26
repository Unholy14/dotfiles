if status is-login
if test -z "$WAYLAND_DISPLAY" -a "$XDG_VTNR" = "1"
        exec start-hyprland
    end
end

fastfetch
alias ls="eza --icons"
starship init fish | source

fish_add_path /home/sevro/.spicetify
