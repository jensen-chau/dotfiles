#
# ~/.bashrc
#
alias CUTF='LANG=en_XX.UTF-8@POSIX '
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ll='ls -l'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias rm='trash-put'

# PS1='[\u@\h \W]\$ '
export EDITOR='vim'

#wine
export WINEARCH="win32"
#end wine
export NVBOARD_HOME=/mnt/newdisk/CMTS/ysyx/ysyx-workbench/nvboard
export CONDA_ENVS_PATH=/mnt/newdisk/Tools/conda/env
export ANDROID_SDK_ROOT=/mnt/newdisk/Tools/AndroidSDK
export ANDROID_AVD_HOME=/mnt/newdisk/Tools/avd

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

