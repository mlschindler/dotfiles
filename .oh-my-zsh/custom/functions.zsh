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
complete -F _kcsc_complete kcsc
# Quickly display / switch kubernetes namespaces
function kcns
{
  local namespace=${1}
  if [[ -z "$namespace" ]]; then
    kubectl get ns
  else
    local context=$(kubectl config current-context)
    echo "Setting context ${context} to namespace ${namespace}..."
    kubectl config set-context ${context} --namespace ${namespace}
  fi
}
function _kcns_complete {
    local word=${COMP_WORDS[COMP_CWORD]}
    local list=$(kubectl get ns --no-headers | awk '{print $1}')
    list=$(compgen -W "$list" -- "$word")
    COMPREPLY=($list)
    return 0
}
complete -F _kcns_complete kcns

# Finds the WAN IP of a given kubernetes node
function kube-node-wan
{
  local node=${1:?}
  kubectl describe node/${node} \
    | awk '/Addresses/ {
        split($2, ips, ",");
        for (i in ips) {
          if ( match(ips[i], /(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)/) == 0 ) {
            print ips[i]
          }
        }
      }'
}
# Lists all kubernetes worker nodes and their WAN IP
function kube-nodes
{
  local nodes=$(kubectl get nodes --no-headers \
    | grep -v 'SchedulingDisabled' \
    | cut -d ' ' -f 1
  )
  for node in $nodes; do
    local node_wan=$(kube-node-wan ${node})
    echo "$node - $node_wan"
  done
}
# Returns the WAN IP for the node on which a given pod is running
function kube-pod-wan
{
  local pod=${1:?}
  local node=$(kubectl describe po ${pod} \
    |awk '/^Node:/ { split($NF, node, "/"); print node[1] }')
  kube-node-wan $node
}
# A quick and dirty way to show the resource availability in a kube cluster
#TODO: This should be re-written and expanded
function kube-capacity {
  local nodes=$(kubectl get no --no-headers | awk '$0 !~ /Disabled/ {print $1}')
  for node in $nodes; do
    echo -n "Node ${node} - "
    kubectl describe no $node \
      | grep -A4 'Allocated resources' \
      | tail -n1 \
      | awk '{print "CPU Requests " $1 " " $2 " Memory Requests: " $5 " " $6}'
  done
}
# Grab a shell / execute a comand on a running pod
function kube-shell
{
  local pod=${1:?}
  shift
  # Some lazy argument parsing to see if a container is specified
  if  [[ "$1" == "-c" ]]; then
    shift
    local container=" -c ${1:?}"
    shift
  fi
  local cols=$(tput cols)
  local lines=$(tput lines)
  local term='xterm'
  local cmd=$@
  cmd=${cmd:-bash}
  kubectl exec -it $pod $container -- env COLUMNS=$cols LINES=$lines TERM=$term "$cmd"
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

# Vault Login

function vault_login
{
  local stg="https://stg.vault.nvidia.com"
  local prod="https://prod.vault.nvidia.com"

  echo "Choose a Vault Namespace: \n \
   1. nvcloudsec \n \
   2. heimdall"
  read V_NAMESPACE
  case $V_NAMESPACE in
    1)
      export VAULT_NAMESPACE="nvcloudsec"
      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
      ;;
    2)
      export VAULT_NAMESPACE="heimdall"
      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
      ;;
    *)
      echo "\n(-) Aborted! Please specify a Vault Namespace..."
      ;;
  esac

  echo "Choose a Vault server: \n \
   1. STG \n \
   2. PROD"
  read V_SERVER
  case $V_SERVER in
    1)
      vault login -address="$stg" -method=ldap username=mschindler
      export VAULT_ADDR="$stg"
      echo "\n(+) Logged into "$stg"."
      ;;
    2)
      vault login -address="$prod" -method=ldap username=mschindler
      export VAULT_ADDR="$prod"
      echo "\n(+) Logged into "$prod"."
      ;;
    *)
      echo "\n(-) Aborted! Please specify a Vault server..."
      ;;
  esac
}


