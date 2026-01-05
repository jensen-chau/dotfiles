#!/bin/bash
# 终止已有的linux-wallpaper进程
pkill linux-wallpaper 2>/dev/null
# 启动新的壁纸引擎进程
nohup linux-wallpaperengine '/home/zjx/MyDisk/SteamLibrary/steamapps/workshop/content/431960/3591115731' --screen-root eDP-1 --scaling fill &>/dev/null &
