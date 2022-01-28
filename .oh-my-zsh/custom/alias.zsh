# General QoL terminal aliases
alias cat="bat"
alias ll="exa -lahF"
alias llt="exa -lahFT"
alias top="sudo htop"
alias sc=shellcheck
alias cdg="cd ~/Repos/work"
alias watch="watch "
eval $(thefuck --alias)

# Python virtualenvwrapper aliases
alias mkenv="mkvirtualenv"
alias rmenv="rmvirtualenv"

# kubectl aliases
alias kc="kubectl"

# dotfile tracking alias 
alias config='/usr/bin/git --git-dir=/Users/mschindler/.cfg/ --work-tree=/Users/mschindler'

# NVIDIA specific aliases
alias aws_login='nvsec configure user && nvsec awsos get-creds --aws-profile default'
