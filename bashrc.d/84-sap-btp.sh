# For SAP's btp CLI

# Where to store the config
export SAPCP_CLIENTCONFIG=$HOME/.config/btp/config.json

# Autocompletion - see
# https://help.sap.com/products/BTP/65de2977205c403bbc107264b8eccf4b/46355fab22814944bedf449a6c953369.html
btpautocomplete="$HOME/.config/btp/autocomplete/scripts/sapbtpcli-autocomplete.plugin.sh"
# shellcheck disable=1090
test -f "$btpautocomplete" \
  && source "$btpautocomplete" \
  && bind 'set show-all-if-ambiguous on'

btpwrapper () {

  local OUTFILE="/tmp/btpcli"

  if "$HOME/bin/btp" "$@" > "$OUTFILE.out" 2> "$OUTFILE.err"; then
    cat "$OUTFILE.out"
  else
    rc=$?
    cat "$OUTFILE.err"
    return $rc
  fi

}

btp () {
  if [[ $1 =~ ^(get|list)$ ]]; then
      btpwrapper "$@" | trunc
  else
      "$HOME/bin/btp" "$@"
  fi
}

btpgo () {

  clear && \
    btplogin "${1:?Specify account}" \
    && btp get accounts/global-account --show-hierarchy \
    && btpctx > "$HOME/.status"

}

bgu () {

  btpguid "$@"

  if [[ $# -gt 1 ]]; then
    btpctx > "$HOME/.status"
  fi

}
