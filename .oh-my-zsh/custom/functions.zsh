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

# AWS Login

function aws_login
{
  local nvcs_dev="arn:aws:iam::703088442575:role/AWSOS-AD-Engineer"
  local nvcs_prod="arn:aws:iam::515825426174:role/AWSOS-AD-Engineer"
  echo "Choose an AWS account: \n \
   1. nvcs_dev \n \
   2. nvcs_prod"
  read ARN
  case $ARN in
    1)
      nvsec awsos get-creds --role-arn="$nvcs_dev" --aws-profile nvcs-dev
      echo "\n(+) Credentials written to nvcs-dev profile."
      ;;
    2)
      nvsec awsos get-creds --role-arn="$nvcs_prod" --aws-profile nvcs-prod
      echo "\n(+) Credentials written to nvcs-prod profile."
      ;;
    *)
      echo "\n(-) Aborted! Please specify an AWS account..."
      ;;
  esac
}

# Vault Login

function vault_login
{
  local stg="https://stg.vault.nvidia.com"
  local prod="https://prod.vault.nvidia.com"
  echo "Choose a Vault server: \n \
   1. STG \n \
   2. PROD"
  read V_SERVER
  case $V_SERVER in
    1)
      vault login -address="$stg" -method=ldap username=mschindler
      echo "\n(+) Logged into "$stg"."
      ;;
    2)
      vault login -address="$prod" -method=ldap username=mschindler
      echo "\n(+) Logged into "$prod"."
      ;;
    *)
      echo "\n(-) Aborted! Please specify a Vault server..."
      ;;
  esac
}

#function aws_login
#{
#  local aws_account=${1}
#  if [[ -z "$aws_account"  ]]; then
#    echo "Please provide a role ARN!"
#  else
#    nvsec awsos get-creds --role-arn=${aws_account} --aws-profile default
#  fi
#}
#
#
#function vault_login
#{
#  local vault_server=${1}
#  if [[ -z "$vault_server" ]]; then
#    echo "Please specify a Vault server address: \n \
#      1. \$VAULT_STG\n \
#      2. \$VAULT_PROD"
#    else
#      vault login -address=${vault_server} -method=ldap username=mschindler
#    fi
#}
