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
