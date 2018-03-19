#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get default starting strings
# shellcheck source=scritps/set_tmux_title.sh
. $CURRENT_DIR/defaults.sh

# Attempt to get all applicable profiles
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile" 2>/dev/null >/dev/null
fi
if [ -f "$HOME/.tmux/profile" ]; then
    source "$HOME/.tmux/profile" 2>/dev/null >/dev/null
fi

TMUX_CONF=$(tmux show-option -gqv @tmux_conf | tr -d "[:space:]")
if [ -f "$TMUX_CONF" ]; then
    source "$TMUX_CONF" 2>/dev/null >/dev/null
fi

# Turn tmux titles on
tmux set -g set-titles on

main() {
    # Actually set the titles
    # shellcheck source=scritps/set_tmux_title.sh
    . $CURRENT_DIR/scripts/set_tmux_title.sh

    if [ -n "$tmux_set_window_status" ]; then
        tmux set-option -gq @tmux_set_window_status 'true'
    fi

    if [[ $(tmux show-option -gqv @tmux_set_window_status | tr -d "[:space:]") == 'true' ]]; then
        # Only globally set the widow-current-status-format once, as it is modified
        # by other apps
        update_win=$(tmux show-option -gqv @win-status-set | tr -d "[:space:]")
        if [[ "$update_win" != 'true' ]]; then
            tmux set-window-option -g window-status-current-format "${tmux_win_current_fmt}"
            tmux set-option -gq @win-status-set 'true'
        fi
        tmux set-window-option -g window-status-format "${tmux_win_other_fmt}"
    fi
}
main
