#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data
mkdir -p /data/.openclaw
chown -R openclaw:openclaw /data/.openclaw

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

OPENCLAW_UPDATE_MARKER="/data/.openclaw/.openclaw-updated"
AGENT_BROWSER_MARKER="/data/.openclaw/.agent-browser-installed"

if [ ! -f "$OPENCLAW_UPDATE_MARKER" ]; then
  if command -v openclaw >/dev/null 2>&1; then
    echo "[entrypoint] Running one-time openclaw update..."
    if openclaw update; then
      touch "$OPENCLAW_UPDATE_MARKER"
      chown openclaw:openclaw "$OPENCLAW_UPDATE_MARKER" 2>/dev/null || true
      echo "[entrypoint] openclaw update completed"
    else
      echo "[entrypoint] openclaw update failed; continuing startup"
    fi
  fi
fi

if [ ! -f "$AGENT_BROWSER_MARKER" ]; then
  if command -v agent-browser >/dev/null 2>&1; then
    echo "[entrypoint] Running one-time agent-browser install..."
    if gosu openclaw agent-browser install; then
      touch "$AGENT_BROWSER_MARKER"
      chown openclaw:openclaw "$AGENT_BROWSER_MARKER" 2>/dev/null || true
      echo "[entrypoint] agent-browser install completed"
    else
      echo "[entrypoint] agent-browser install failed; continuing startup"
    fi
  fi
fi

exec gosu openclaw node src/server.js
