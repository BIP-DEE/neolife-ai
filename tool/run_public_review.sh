#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8098}"
HOST="${HOST:-0.0.0.0}"
TUNNEL_LOG=""
INITIAL_PORT="${PORT}"

port_in_use() {
  lsof -nP -iTCP:"${1}" -sTCP:LISTEN >/dev/null 2>&1
}

select_port() {
  local candidate="${PORT}"
  while port_in_use "${candidate}"; do
    echo "Port ${candidate} is already in use. Trying the next port..."
    candidate=$((candidate + 1))
  done
  PORT="${candidate}"
}

select_port

echo "Starting NeoLife AI review build..."
if [[ "${PORT}" != "${INITIAL_PORT}" ]]; then
  echo "Requested port ${INITIAL_PORT} was unavailable. Using port ${PORT} instead."
fi
echo "Local review URL: http://127.0.0.1:${PORT}"
echo "Use the 'Enter review mode' action on the welcome screen to bypass authentication."

cleanup() {
  if [[ -n "${TUNNEL_LOG:-}" && -f "${TUNNEL_LOG}" ]]; then
    rm -f "${TUNNEL_LOG}" 2>/dev/null || true
  fi
  if [[ -n "${TUNNEL_PID:-}" ]]; then
    kill "${TUNNEL_PID}" 2>/dev/null || true
  fi
  if [[ -n "${FLUTTER_PID:-}" ]]; then
    kill "${FLUTTER_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

wait_for_server() {
  local attempt
  for attempt in $(seq 1 60); do
    if curl -fsS "http://127.0.0.1:${PORT}" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

start_cloudflared() {
  local attempt public_url
  TUNNEL_LOG="$(mktemp)"
  echo "Opening a public Cloudflare tunnel for external review..."
  cloudflared tunnel --url "http://127.0.0.1:${PORT}" --no-autoupdate >"${TUNNEL_LOG}" 2>&1 &
  TUNNEL_PID=$!

  for attempt in $(seq 1 20); do
    public_url="$(grep -Eo 'https://[-[:alnum:].]+trycloudflare.com' "${TUNNEL_LOG}" | tail -n 1 || true)"
    if [[ -n "${public_url}" ]]; then
      echo "Public review URL: ${public_url}"
      return 0
    fi
    if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  echo "Cloudflare tunnel did not come up cleanly. Falling back if another tunnel is available..."
  kill "${TUNNEL_PID}" 2>/dev/null || true
  TUNNEL_PID=""
  rm -f "${TUNNEL_LOG}" 2>/dev/null || true
  TUNNEL_LOG=""
  return 1
}

start_localtunnel() {
  local attempt public_url
  TUNNEL_LOG="$(mktemp)"
  echo "Opening a public LocalTunnel URL for external review..."
  npx --yes localtunnel --port "${PORT}" >"${TUNNEL_LOG}" 2>&1 &
  TUNNEL_PID=$!

  for attempt in $(seq 1 30); do
    public_url="$(grep -Eo 'https://[-[:alnum:]]+\.loca\.lt' "${TUNNEL_LOG}" | tail -n 1 || true)"
    if [[ -n "${public_url}" ]]; then
      echo "Public review URL: ${public_url}"
      return 0
    fi
    if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  echo "LocalTunnel did not return a public URL."
  kill "${TUNNEL_PID}" 2>/dev/null || true
  TUNNEL_PID=""
  rm -f "${TUNNEL_LOG}" 2>/dev/null || true
  TUNNEL_LOG=""
  return 1
}

(
  cd "${ROOT_DIR}"
  HOME="${ROOT_DIR}" ./flutter/bin/flutter run \
    -d web-server \
    --web-hostname="${HOST}" \
    --web-port="${PORT}"
) &
FLUTTER_PID=$!

if ! wait_for_server; then
  echo "Flutter web-server did not become ready on port ${PORT}."
  exit 1
fi

echo "Flutter web-server is ready on http://127.0.0.1:${PORT}"

if command -v cloudflared >/dev/null 2>&1 && start_cloudflared; then
  :
elif command -v npx >/dev/null 2>&1 && start_localtunnel; then
  :
else
  cat <<EOF
No working public tunnel is available, so this run will stay local to your machine/network.

Install one of these and rerun the script:
  brew install cloudflared
  npm install -g localtunnel
EOF
fi

wait "${FLUTTER_PID}"
