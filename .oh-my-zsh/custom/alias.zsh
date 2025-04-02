# General QoL terminal aliases
alias cat="bat"
alias ll="lsd -lahF"
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
alias vpn_durham='sudo openconnect ngvpn04.vpn.nvidia.com/SAML-EXT --useragent="AnyConnect whatever"'
alias vpn_austin='sudo openconnect ngvpn03.vpn.nvidia.com/SAML-EXT --useragent="AnyConnect whatever"'
alias vpn_fix='sudo killall configd'
