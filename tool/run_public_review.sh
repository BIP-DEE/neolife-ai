#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8098}"
HOST="${HOST:-0.0.0.0}"

echo "Starting NeoLife AI review build on http://${HOST}:${PORT}"
echo "Use the 'Enter review mode' action on the welcome screen to bypass authentication."

if command -v cloudflared >/dev/null 2>&1; then
  echo "Opening a public Cloudflare tunnel for external review..."
else
  cat <<EOF
cloudflared is not installed, so this run will stay local to your machine/network.
To expose a public review URL, install cloudflared and rerun this script:
  brew install cloudflared
EOF
fi

cleanup() {
  if [[ -n "${TUNNEL_PID:-}" ]]; then
    kill "${TUNNEL_PID}" 2>/dev/null || true
  fi
  if [[ -n "${FLUTTER_PID:-}" ]]; then
    kill "${FLUTTER_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

(
  cd "${ROOT_DIR}"
  HOME="${ROOT_DIR}" ./flutter/bin/flutter run \
    -d web-server \
    --web-hostname="${HOST}" \
    --web-port="${PORT}"
) &
FLUTTER_PID=$!

if command -v cloudflared >/dev/null 2>&1; then
  cloudflared tunnel --url "http://127.0.0.1:${PORT}" &
  TUNNEL_PID=$!
fi

wait "${FLUTTER_PID}"
