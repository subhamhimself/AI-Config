#!/bin/bash

echo ">>> Ensuring Claude Code is installed..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

echo ">>> Starting SSH..."
exec /usr/sbin/sshd -D
