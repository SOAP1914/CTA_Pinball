#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${ROOT_DIR}/.venv"
GODOT_DIR="${ROOT_DIR}/.tools/godot"
GODOT_BIN="${GODOT_DIR}/Godot_v4.5-stable_linux.x86_64"
GODOT_URL="https://github.com/godotengine/godot/releases/download/4.5-stable/Godot_v4.5-stable_linux.x86_64.zip"

python3 -m venv "${VENV_DIR}"
"${VENV_DIR}/bin/python" -m pip install --upgrade pip
"${VENV_DIR}/bin/pip" install mpf

if [[ ! -x "${GODOT_BIN}" ]]; then
  mkdir -p "${GODOT_DIR}"
  tmp_zip="$(mktemp)"
  curl -L -o "${tmp_zip}" "${GODOT_URL}"
  unzip -o "${tmp_zip}" -d "${GODOT_DIR}"
  rm -f "${tmp_zip}"
  chmod +x "${GODOT_BIN}"
fi

echo "MPF: $("${VENV_DIR}/bin/mpf" --version)"
echo "Godot: $("${GODOT_BIN}" --version)"
