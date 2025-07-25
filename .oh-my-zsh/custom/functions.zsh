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
nv-vpn () {
        local command="${1:-s}"
        local -r _vpn_bin='/opt/cisco/anyconnect/bin/vpn'
        local -r _vpn_net='US Santa Clara (NGVPN01)'
        case "$command" in
                ('s') echo -e 'Checking current VPN status...\n'
                        eval "${_vpn_bin} -s status" ;;
                ('c') echo -e 'Connecting to VPN...\n'
                        eval "${_vpn_bin} -s connect '$_vpn_net'" ;;
                ('d') echo -e 'Disconnecting from VPN...\n'
                        eval "${_vpn_bin} -s disconnect" ;;
                (*) echo "Invalid option '${command}' ([(s)tatus]|(c)onnect|(d)isconnect)"
                        return 1 ;;
        esac
}

# calls login scripts
login () {
        nv-vpn c
        sleep 5
}

# Vault Login

function vault_login() {
  local stg="https://stg.vault.nvidia.com"
  local prod="https://prod.vault.nvidia.com"
  local context=${1}

  if [[ -z "$context" ]]; then
    echo "Available options:"
    echo "  prodsec-devops-stg"
    echo "  prodsec-devops-prod"
    return 0
  fi

  case $context in
    prodsec-devops-stg)
      export VAULT_NAMESPACE="prodsec-devops"
      export VAULT_ADDR="$stg"
      vault login -method=oidc -address="$stg"
      echo "\n(+) Logged into prodsec-devops-stg"
      ;;
    prodsec-devops-prod)
      export VAULT_NAMESPACE="prodsec-devops"
      export VAULT_ADDR="$prod"
      vault login -method=oidc -address="$prod"
      echo "\n(+) Logged into prodsec-devops-prod"
      ;;
    *)
      echo "\n(-) Invalid option: $context"
      echo "Available options: prodsec-devops-stg, prodsec-devops-prod"
      return 1
      ;;
  esac
}

function _vault_login_complete {
    local word=${COMP_WORDS[COMP_CWORD]}
    local list="prodsec-devops-stg prodsec-devops-prod"
    list=$(compgen -W "$list" -- "$word")
    COMPREPLY=($list)
    return 0
}
complete -F _vault_login_complete vault_login
#function vault_login
#{
#  local stg="https://stg.vault.nvidia.com"
#  local prod="https://prod.vault.nvidia.com"
#
#  echo "Choose a Vault Namespace: \n \
#   1. nvcloudsec \n \
#   2. heimdall \n \
#   3. simple-signing-service \n \
#   4. prodsec-splunk \n \
#   5. prodsec-devops"
#  read V_NAMESPACE
#  case $V_NAMESPACE in
#    1)
#      export VAULT_NAMESPACE="nvcloudsec"
#      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
#      ;;
#    2)
#      export VAULT_NAMESPACE="heimdall"
#      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
#      ;;
#    3)
#      export VAULT_NAMESPACE="simple-signing-service"
#      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
#      ;;
#    4)
#      export VAULT_NAMESPACE="prodsec-splunk"
#      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
#      ;;
#    5)
#      export VAULT_NAMESPACE="prodsec-devops"
#      echo "\n(+) Namespace set to "$VAULT_NAMESPACE"."
#      ;;
#    *)
#      echo "\n(-) Aborted! Please specify a Vault Namespace..."
#      ;;
#  esac
#
#  echo "Choose a Vault server: \n \
#   1. STG \n \
#   2. PROD \n \
#   3. prodsec-devops STG \n \
#   4. prodsec-devops PROD"
#  read V_SERVER
#  case $V_SERVER in
#    1)
#      vault login -address="$stg" -method=oidc -path=oidc-admins role=namespace-admin
#      export VAULT_ADDR="$stg"
#      echo "\n(+) Logged into "$stg"."
#      ;;
#    2)
#      vault login -address="$prod" -method=oidc -path=oidc-admins role=namespace-admin
#      export VAULT_ADDR="$prod"
#      echo "\n(+) Logged into "$prod"."
#      ;;
#    3)
#      vault login -address="$stg" -method=oidc
#      export VAULT_ADDR="$stg"
#      echo "\n(+) Logged into "$stg"."
#      ;;
#    4)
#      vault login -address="$prod" -method=oidc
#      export VAULT_ADDR="$prod"
#      echo "\n(+) Logged into "$prod"."
#      ;;
#    *)
#      echo "\n(-) Aborted! Please specify a Vault server..."
#      ;;
#  esac
#}


