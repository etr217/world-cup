#!/usr/bin/env bash
cd "$(dirname "$0")"
PORT="${1:-8000}"
echo "Local bracket scorer: http://localhost:${PORT}/"
echo "Using brackets/manifest.local.json on localhost"
exec python3 -m http.server "$PORT"
