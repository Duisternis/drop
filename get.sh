#!/bin/sh
# usage, from a repo root: sh get.sh <key> [install args, default: code --link]
set -e
here="$(cd "$(dirname "$0")" && pwd)"
key="${1:-$PATCH_KEY}"
[ $# -gt 0 ] && shift
if [ -z "$key" ]; then
  printf 'key: ' > /dev/tty; stty -echo < /dev/tty; read -r key < /dev/tty; stty echo < /dev/tty; echo > /dev/tty
fi
dir="${PATCH_DIR:-$HOME/.patch}"
tmp="$(mktemp -d)"
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -md sha256 -a -pass "pass:$key" < "$here/patch.enc" > "$tmp/patch.tgz" || { echo "wrong key"; exit 1; }
rm -rf "$dir" && mkdir -p "$dir" && tar xzf "$tmp/patch.tgz" -C "$dir" && rm -rf "$tmp"
[ $# -eq 0 ] && set -- code --link
if [ "$(git rev-parse --show-toplevel 2>/dev/null)" = "$(pwd -P)" ]; then
  python3 "$dir/install.py" "$@"
else
  echo "patch updated in $dir; not at a repo root, so nothing installed"
fi
