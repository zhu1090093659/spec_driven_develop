#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing spec-driven-develop ==="
echo ""

echo "[1/3] Installing to Cursor..."
bash "$SCRIPT_DIR/install-cursor.sh"
echo ""

echo "[2/3] Installing to Codex..."
bash "$SCRIPT_DIR/install-codex.sh"
echo ""

echo "[3/4] Installing to OpenCode..."
bash "$SCRIPT_DIR/install-opencode.sh"
echo ""

echo "[4/4] Syncing to ~/.agents/skills..."
bash "$SCRIPT_DIR/install-agents.sh"
echo ""

echo "=== Done ==="
echo ""
echo "For Claude Code:"
echo "  /plugin marketplace add zhu1090093659/spec_driven_develop"
echo "  /plugin install spec-driven-develop@spec-driven-develop"
echo ""
echo "For OpenCode, quit and restart the app after installation."
