#!/usr/bin/env bash
# Shared colors and helpers for agentic scripts

BOLD=$'\033[1m'
DIM=$'\033[2m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

info()  { echo -e "${CYAN}$*${RESET}"; }
ok()    { echo -e "${GREEN}✓ $*${RESET}"; }
warn()  { echo -e "${YELLOW}$*${RESET}"; }
err()   { echo -e "${RED}Error: $*${RESET}" >&2; exit 1; }

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
