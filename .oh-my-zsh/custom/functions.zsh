# Quickly display / switch kubernetes contexts
function kcsc
{
  local context=${1}
  if [[ -z "$context" ]]; then
    kubectl config get-contexts
  else
    kubectl config use-context ${context}
  fi
}
function _kcsc_complete {
    local word=${COMP_WORDS[COMP_CWORD]}
    local list=$(kubectl config get-contexts --no-headers | tr -d '\*' | awk '{print $1}')
    list=$(compgen -W "$list" -- "$word")
    COMPREPLY=($list)
    return 0
}

# 2U VPN Login
2u-vpn () {
        local command="${1:-s}"
        local -r _vpn_bin='/opt/cisco/anyconnect/bin/vpn'
        local -r _vpn_net='2U Corp Network'
        case "$command" in
                ('s') echo -e 'Checking current VPN status...\n'
                        eval "${_vpn_bin} -s status" ;;
                ('c') echo -e 'Connecting to VPN...\n'
                        _vpn_autoconnect ;;
                ('d') echo -e 'Disconnecting from VPN...\n'
                        eval "${_vpn_bin} -s disconnect" ;;
                (*) echo "Invalid option '${command}' ([(s)tatus]|(c)onnect|(d)isconnect)"
                        return 1 ;;
        esac
}

# calls login scripts
login () {
        2u-vpn c
        sleep 5
        /usr/local/bin/_login
}
