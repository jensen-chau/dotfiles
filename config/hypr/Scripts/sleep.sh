swayidle -w timeout 10 'hyprlock' \
            timeout 10 'hyprctl dispatch dpms off' \
            resume 'hyprctl dispatch dpms on' \
            timeout 900 'systemctl suspend' \
            before-sleep 'hyprlock' &
