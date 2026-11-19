# macOS Keychain helpers: API keys live in the Keychain, never in files or shell history.
#
#   ks-set anthropic-api-key      # security prompts for the value (hidden); stores or updates
#   ks-get anthropic-api-key      # prints the value; fails loudly when the item is missing
#   ks-del anthropic-api-key
#   ks-with ANTHROPIC_API_KEY anthropic-api-key tessera run --pod lcqv-1 --type daily
#
# When to read the Keychain: at the moment a command needs the key. ks-with puts the key in
# that one command's environment only. Exporting it from ~/.zshrc.local instead
# (export ANTHROPIC_API_KEY=$(ks-get anthropic-api-key)) gives it to every shell and to every
# agent session started from one, where any tool call can read it.

[[ "$OSTYPE" == darwin* ]] || return 0

ks-set() {
  [[ -n "$1" ]] || { print -u2 "usage: ks-set <service>"; return 2; }
  security add-generic-password -U -a "$USER" -s "$1" -w
}

ks-get() {
  [[ -n "$1" ]] || { print -u2 "usage: ks-get <service>"; return 2; }
  security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null \
    || { print -u2 "ks-get: no Keychain item '$1'; store it with: ks-set $1"; return 1; }
}

ks-del() {
  [[ -n "$1" ]] || { print -u2 "usage: ks-del <service>"; return 2; }
  security delete-generic-password -a "$USER" -s "$1" >/dev/null
}

ks-with() {
  [[ $# -ge 3 ]] || { print -u2 "usage: ks-with <VAR> <service> <command...>"; return 2; }
  local var=$1 service=$2 value
  shift 2
  value=$(ks-get "$service") || return 1
  ( export "$var=$value"; "$@" )
}
