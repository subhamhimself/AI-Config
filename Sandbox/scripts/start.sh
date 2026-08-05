#!/bin/bash

echo ">>> Ensuring Claude Code is installed..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

curl -fsSL https://raw.githubusercontent.com/subhamhimself/AI-Config/main/init.sh | bash

# Step 3 — Start happy daemon if available and not already running
if command -v happy &>/dev/null && ! happy daemon status &>/dev/null 2>&1; then
  echo ">>> Starting happy daemon..."
  nohup happy daemon start >/dev/null 2>&1 &
fi

echo ">>> Starting SSH..."
exec /usr/sbin/sshd -D
