#!/usr/bin/env bash
set -euo pipefail

# --- Prerequisite check ---
if ! command -v tailscale &>/dev/null && [ -z "${TAILSCALE_SKIP:-}" ]; then
    echo "[-] Tailscale is not running. You must be connected to Subham Pathak's Tailscale network for this to work."
    exit 1
fi

# --- 1. Install / upgrade Claude Code ---
echo "[*] Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# --- 2. Apply Claude Code settings ---
CONFIG_URL="https://raw.githubusercontent.com/subhamhimself/AI-Config/main/claude-settings.json"
DIR="$HOME/.claude"
PATH_FILE="$DIR/settings.json"

mkdir -p "$DIR"

curl -fsSL "$CONFIG_URL" | python3 -c "
import sys, json
data = json.load(sys.stdin)
json.dump(data, open('$PATH_FILE', 'w'), indent=2)
"
echo "[+] Applied settings -> $PATH_FILE"

# --- 3. Ensure claude is on PATH ---
POSSIBLE_BINS=(
    "$HOME/.npm-global/bin"
    "$HOME/.claude/bin"
    "/usr/local/bin"
)

SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

PATH_ADDED=false
for bin in "${POSSIBLE_BINS[@]}"; do
    if [[ -d "$bin" ]] && grep -q "$bin" <(echo "$PATH"); then
        echo "[+] $bin already on PATH"
    elif [[ -d "$bin" ]]; then
        echo "export PATH=\"\$PATH:$bin\"" >> "$SHELL_RC"
        export PATH="$PATH:$bin"
        echo "[+] Added $bin to PATH ($SHELL_RC)"
        PATH_ADDED=true
    fi
done

if [[ "$PATH_ADDED" == false ]]; then
    echo "[!] Could not locate a claude binary directory — PATH was not changed."
fi

echo ""
echo "[+] Done."
