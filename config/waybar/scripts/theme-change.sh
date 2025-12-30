#!/usr/bin/bash

curthemefile=~/.config/waybar/scripts/.curtheme

if test -s $curthemefile 
then
    curtheme=$(cat $curthemefile)
    rm $HOME/.config/waybar/colors/color.css;
    if [ "$curtheme" == "dark" ]
    then
        ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
        echo "primary" > $curthemefile
    else
        ln -s $HOME/.config/waybar/colors/dark.css $HOME/.config/waybar/colors/color.css
        echo "dark" > $curthemefile
    fi
else
    echo "primary" > $curthemefile
    ln -s $HOME/.config/waybar/colors/primary.css $HOME/.config/waybar/colors/color.css
fi
    
pkill waybar && waybar &
