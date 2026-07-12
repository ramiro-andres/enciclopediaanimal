#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-8080}"
export TEST_PORT="$PORT"

chmod +x "$DIR/tests/browser_e2e.rb"
ruby "$DIR/tests/browser_e2e.rb"
