if [[ $TERM = "xterm-kitty" ]]; then
    # alias ssh for kitty to allow tmux to work
    alias icat="kitty +kitten icat"
fi

alias locate=plocate
alias ll='ls -alFh'
alias config='/usr/bin/git --git-dir=/home/will/.cfg/ --work-tree=/home/will'
alias paclog='paclog -c'
alias grep='grep -I'
