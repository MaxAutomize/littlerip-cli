#!/bin/sh
set -eu

REPOSITORY="MaxAutomize/littlerip-cli"
RAW_URL="https://raw.githubusercontent.com/$REPOSITORY/main/bin/littlerip"
DEFAULT_INSTALL_DIR="$HOME/.local/bin"
INSTALL_DIR="${LITTLERIP_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
TARGET="$INSTALL_DIR/littlerip"

mkdir -p "$INSTALL_DIR"
temporary_file="$INSTALL_DIR/.littlerip-install-$$"
trap 'rm -f "$temporary_file"' EXIT HUP INT TERM

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)
if [ -n "$script_dir" ] && [ -f "$script_dir/bin/littlerip" ]; then
  cp "$script_dir/bin/littlerip" "$temporary_file"
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$temporary_file"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$temporary_file" "$RAW_URL"
  else
    printf '%s\n' 'LittleRip needs curl or wget to install.' >&2
    exit 1
  fi
fi

chmod 755 "$temporary_file"
mv "$temporary_file" "$TARGET"
trap - EXIT HUP INT TERM

path_updated=false
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    case "${SHELL-}" in
      */zsh) profile="$HOME/.zshrc" ;;
      */bash) profile="$HOME/.bashrc" ;;
      *) profile="$HOME/.profile" ;;
    esac

    marker='# LittleRip CLI'
    if ! grep -Fq "$marker" "$profile" 2>/dev/null; then
      {
        printf '\n%s\n' "$marker"
        printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"'
      } >> "$profile"
    fi
    path_updated=true
    ;;
esac

printf 'Installed littlerip at %s\n' "$TARGET"
if [ "$path_updated" = true ]; then
  printf '%s\n' 'Open a new terminal, then type: littlerip'
else
  printf '%s\n' 'Type: littlerip'
fi
