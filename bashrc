GREEN="\[$(tput setaf 2)\]"
RESET="\[$(tput sgr0)\]"

export EDITOR=nano
export PAGER=less
export PS1="[${GREEN}\u@\h \W${RESET}]>"