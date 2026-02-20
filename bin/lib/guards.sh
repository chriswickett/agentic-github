#!/usr/bin/env bash
# Precondition checks and environment detection

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

require_vars() {
  local missing=()
  for var in "$@"; do
    [[ -n "${!var:-}" ]] || missing+=("$var")
  done
  (( ${#missing[@]} == 0 )) || err "Missing required variables: ${missing[*]}"
}

require_commands() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || err "$cmd is not installed"
  done
}

require_gh_auth() {
  gh auth status &>/dev/null 2>&1 \
    || err "Not authenticated with GitHub CLI. Run 'gh auth login' first."
}

detect_remote() {
  git -C "$1" remote get-url origin 2>/dev/null \
    | sed -E 's|.*github\.com[:/]||; s|\.git$||'
}
