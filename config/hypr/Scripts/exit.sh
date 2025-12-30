#!/bin/bash
cd ~/.config/hypr/Scripts 
# 显示确认对话框
result=$(./exit)

# 处理结果
case $result in
    "confirmed")
        echo "执行确认操作"
        $(hyprctl dispatch exit)# 在此处添加确认后要执行的命令
        ;;
    "cancelled")
        echo "操作已取消"
        # 在此处添加取消后要执行的命令
        ;;
    *)
        echo "未知结果: $result"
        ;;
esac
