#alias CUTF='LANG=en_XX.UTF-8@POSIX '
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ll='ls -l'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
#alias rm='trash-put'

alias cdgwy='cd ~/MyDisk2/Project/gwy'
alias cdstm32='cd ~/MyDisk/Project/STM32Project/'
alias cdcfg='cd ~/.config/'
alias cdgithub='cd /mnt/newdisk/Project/github/'
alias cdvm='cd /mnt/newdisk2/VM'
alias cdProject='cd /mnt/newdisk/Project/'
alias cdOpen='cd /mnt/newdisk/Project/C-project/opengl/'

#esp32
alias get_idf='source /mnt/newdisk/Project/esp/esp-idf-v5.3.1/export.sh'
export IDF_PATH='/mnt/newdisk/Project/esp/esp-idf-v5.3.1'



function bliss {
    cdvm
    cd bliss
    ./bliss
}


function update-dotfile {
    cd ~/dotfiles 
    git add .
    echo "save success"
    git commit -m "dotfile update"
    echo "commit success"
    git push
}

function changeWallpaper {
    linux-wallpaperengine '/home/zjx/MyDisk/SteamLibrary/steamapps/workshop/content/431960/1082586397' --screen-root eDP-1 --scaling fill
}

function enable_anaconda {
    source /opt/anaconda/bin/activate root
}

export EDITOR='nvim'

#wine
# export WINEARCH="win32"
#end wine
export NVBOARD_HOME=/mnt/newdisk/CMTS/ysyx/ysyx-workbench/nvboard
export CONDA_ENVS_PATH=/mnt/newdisk/Tools/conda/env
export ANDROID_SDK_ROOT=/mnt/newdisk/Tools/AndroidSDK
export ANDROID_AVD_HOME=/mnt/newdisk/Tools/avd

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

## gemini
export GOOGLE_CLOUD_PROJECT=126185430060

# cargo bin
export PATH=/home/zjx/.cargo/bin:$PATH 

# 插件 !! 加载顺序必须注意
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# 启用彩色提示符
autoload -U colors && colors

# 每次刷新提示符
setopt prompt_subst

# 设置提示符
PROMPT='%{$fg[green]%}%n%{$reset_color%}|%{$fg[yellow]%}%1~%{$reset_color%}%{$fg[blue]%}$(git branch --show-current 2&> /dev/null | xargs -I branch echo "(branch)")%{$reset_color%}❱ '
