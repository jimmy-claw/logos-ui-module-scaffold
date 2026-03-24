#!/bin/bash
set -e

# Build logos-qt-mcp test framework (one-time)
echo "Building logos-qt-mcp (from logos-basecamp)..."
cd ~/logos-basecamp
export PATH=$HOME/.nix-profile/bin:$PATH
nix build .#x86_64-linux.logosQtMcp -o result-mcp 2>/dev/null || true

# Run the tests (app must be running)
echo "Running UI tests..."
export LOGOS_QT_MCP=$(pwd)/result-mcp
node tests/ui-tests.mjs "$@"
