# macOS Keychain helpers — store and retrieve API keys / secrets
# Usage:
#   ks-set anthropic-api-key "sk-ant-..."   # store (or update)
#   ks-get anthropic-api-key                # retrieve
#   ks-del anthropic-api-key                # delete
#
# In ~/.zshrc.local or a per-project .envrc:
#   export ANTHROPIC_API_KEY=$(ks-get anthropic-api-key)

[[ "$OSTYPE" == darwin* ]] || return 0

ks-set() { security add-generic-password -U -a "$USER" -s "$1" -w "$2"; }
ks-get() { security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null; }
ks-del() { security delete-generic-password -a "$USER" -s "$1"; }
