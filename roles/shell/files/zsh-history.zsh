## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"

[ "$HISTSIZE" -lt 5000 ] && HISTSIZE=5000
[ "$SAVEHIST" -lt 5000 ] && SAVEHIST=5000

## History command configuration
setopt EXTENDED_HISTORY       # record timestamp of command in HISTFILE
setopt SHARE_HISTORY          # share command history data

setopt HIST_EXPIRE_DUPS_FIRST    # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion
