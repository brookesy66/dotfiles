#!/bin/bash

#        -lf/nf/cf color
#            Defines the foreground color for low, normal and critical notifications respectively.
#
#        -lb/nb/cb color
#            Defines the background color for low, normal and critical notifications respectively.
#
#        -lfr/nfr/cfr color
#            Defines the frame color for low, normal and critical notifications respectively.

#[ -f "$HOME/.cache/wal/colors.sh" ] && . "$HOME/.cache/wal/colors.sh"
[ -f "$HOME/.cache/wal/colors.sh" ] && "$HOME/.cache/wal/colors.sh"

# consider using pkill, not sure this works for some reason
#pidof dunst && killall dunst
pidof dunst && pkill dunst

dunst -nf  "${color15:-#cccccc}" \
      -nb  "${color0:-#bbbbbb}" \
      -nfr "${color15:-#aaaaaa}" \
      -lf  "${color15:-#ffffff}" \
      -lb  "${color0:-#eeeeee}" \
#      -lfr "${color2:-#dddddd}" \
#      -nf  "${color3:-#cccccc}" \
#      -nb  "${color4:-#bbbbbb}" \
#      -nfr "${color5:-#aaaaaa}" \
#      -cf  "${color6:-#999999}" \
#      -cb  "${color7:-#888888}" \
#      -cfr "${color8:-#777777}"
> /dev/null 2>&1 &
