#!/usr/bin/env bash
set -euo pipefail
# Linux/macOS helper. On Windows, use tools/run_mpf.ps1 instead.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${ROOT_DIR}/.venv/bin/mpf" "$@"
