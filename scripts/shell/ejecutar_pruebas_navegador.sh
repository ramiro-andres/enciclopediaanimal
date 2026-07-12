#!/bin/bash
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PORT="${1:-8080}"
export TEST_PORT="$PORT"

chmod +x "$ROOT/tests/browser_e2e.rb"
ruby "$ROOT/tests/browser_e2e.rb"
