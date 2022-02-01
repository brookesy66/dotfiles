if [[ $TERM = "xterm-kitty" ]]; then
    # alias ssh for kitty to allow tmux to work
    alias ssh='kitty +kitten ssh'
    alias icat="kitty +kitten icat"
fi

alias locate=plocate
alias ll='ls -alFh'
alias ipython=ipython3
alias config='/usr/bin/git --git-dir=/home/will/.cfg/ --work-tree=/home/will'
