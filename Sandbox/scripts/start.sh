#!/bin/bash

echo ">>> Ensuring Claude Code is installed..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

curl -fsSL https://raw.githubusercontent.com/subhamhimself/AI-Config/main/init.sh | bash


echo ">>> Starting SSH..."
exec /usr/sbin/sshd -D
