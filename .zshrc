# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '(%b)'

# Specific to FreeBSD/OSX
export CLICOLOR=YES

# Aliases
alias ls='ls -lh'
alias llh='ls -lh'
alias du='du -h'
alias df='df -h'
alias vi='vim'
alias kc='/opt/homebrew/bin/kubectl'
alias dc='/usr/local/bin/docker compose'

# Set Prompt
setopt PROMPT_SUBST
PROMPT='%F{white}%t%f [%F{cyan}%~%f %F{green}${vcs_info_msg_0_}%f] '

# History: file and size
export HISTFILE=~/.zsh_history
export HISTFILESIZE=10000
export HISTSIZE=10000

# History: show more than default of 15
alias history='history -1000'

# History: add timestamps
setopt EXTENDED_HISTORY

# History: append immediately instead of when shell exits
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "

# History: handle combine repeated commands
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# History: verify historical command before executing it
setopt histverify

# disable tab auto-complete auto-menu
unsetopt automenu

# from "brew install mysql-client"
export PATH="/usr/local/opt/mysql-client/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/mysql-client/lib"
export CPPFLAGS="-I/usr/local/opt/mysql-client/include"

export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
