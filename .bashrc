# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000
# PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
    *)
	;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some aliases
alias l='ls -la'
alias vi='nvim'
alias vim='nvim'
alias oc='opencode'
alias co='copilot'
alias ..='j ..'
alias ...='j ../..'
# alias obsidian='/snap/obsidian/current/obsidian --no-sandbox'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
    fi
fi

export EDITOR=nvim
export LC_ALL="ja_JP.UTF-8"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$PATH:/usr/local/cuda/bin"
export PATH="$PATH:$HOME/.npm-packages/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init bash --cmd j)"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"
export LS_COLORS="$LS_COLORS:ow=01;34:"

if [ -f ~/.bash_ubuntu ]; then
    . ~/.bash_ubuntu
fi

if [ -f ~/.bash_wsl ]; then
    . ~/.bash_wsl
fi

# ==========================================
# 1行ステータスモニター (sysmon)
# ==========================================
_sysmon_update() {
    # ネットワークインターフェースの自動取得
    local I=$(ip route | awk '/default/ {print $5}' | head -n1)
    
    # 現在のネットワーク転送量を取得
    local R1=$(cat /sys/class/net/$I/statistics/rx_bytes 2>/dev/null || echo 0)
    local T1=$(cat /sys/class/net/$I/statistics/tx_bytes 2>/dev/null || echo 0)

    # CPU使用率（正確な値を取るため、ここで約1秒待機します）
    local CPU=$(vmstat 1 2 | tail -1 | awk '{print 100-$15}')

    # 1秒経過後のネットワーク転送量を取得
    local R2=$(cat /sys/class/net/$I/statistics/rx_bytes 2>/dev/null || echo 0)
    local T2=$(cat /sys/class/net/$I/statistics/tx_bytes 2>/dev/null || echo 0)

    # GPU・メモリ・日時の取得
    local GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0)
    local MEM=$(free -h | awk '/^Mem:/ {print $3"/"$2}' | sed 's/i//g')
    local D=$(date +"%m-%d %H:%M")

    # 1秒あたりの通信速度を計算 (KB/s)
    local RX=$(((R2 - R1) / 1024))
    local TX=$(((T2 - T1) / 1024))

    # 出力（カラーコードとNerd Fontsアイコンを使用）
    printf " ⇄ ⬇ %sK | ⬆ %sK  \033[34m\033[0m   %s%%  \033[34m\033[0m  󰢮 %s%%  \033[34m\033[0m   %s  \033[34m\033[0m   %s\n" \
        "$RX" "$TX" "$CPU" "$GPU" "$MEM" "$D"
}

# watch は内部で /bin/sh (dash) を使うため、関数定義をそのまま渡すと
# bash 構文エラーになる。そこで関数定義を含む実行用スクリプトを
# 一時ファイルに書き出し、それを bash に実行させる。
sysmon() {
    local tmp="$(mktemp /tmp/sysmon.XXXXXX.sh)"
    {
        declare -f _sysmon_update
        echo '_sysmon_update'
    } > "$tmp"
    watch -c -t -n 4 bash "$tmp"
    rm -f "$tmp"
}


# Added by Antigravity CLI installer
export PATH="/home/tk/.local/bin:$PATH"

export MCAT_THEME=everforest
