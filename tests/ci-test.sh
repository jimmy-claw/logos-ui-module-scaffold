#!/bin/bash
set -e

export PATH=$HOME/.nix-profile/bin:$PATH

# Build logos-qt-mcp
cd ~/logos-basecamp
nix build .#x86_64-linux.logosQtMcp -o result-mcp 2>/dev/null || true
export LOGOS_QT_MCP=$(pwd)/result-mcp

# Build basecamp with inspector
nix build .#x86_64-linux.appDistributedWithInspector -o result-app 2>/dev/null || {
  echo "Could not build appDistributedWithInspector — fallback to regular build"
  nix build .#x86_64-linux.app -o result-app 2>/dev/null
}

# Start Xvfb
pkill -f "Xvfb :99" 2>/dev/null || true
Xvfb :99 -screen 0 1920x1080x24 &
sleep 2

# Start app
DISPLAY=:99 ./result-app/bin/logos-basecamp &
APP_PID=$!
sleep 10

# Start MCP server
node result-mcp/mcp-server/index.mjs &
MCP_PID=$!

# Run tests
node tests/ui-tests.mjs || true

# Cleanup
kill $APP_PID $MCP_PID 2>/dev/null || true
pkill -f "Xvfb :99" 2>/dev/null || true
