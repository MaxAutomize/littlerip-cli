#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
command_path="$project_dir/bin/littlerip"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

sh -n "$command_path"
sh -n "$project_dir/install.sh"

output=$($command_path)
[ "$output" = 'littlerip' ] || fail 'redirected output must be exactly littlerip'

version=$($command_path --version)
[ "$version" = '1.0.0' ] || fail 'version must be 1.0.0'

help=$($command_path --help)
printf '%s' "$help" | grep -Fq 'Usage: littlerip' || fail 'help must contain usage'

if $command_path --not-a-real-option >/dev/null 2>&1; then
  fail 'unknown options must fail'
else
  status=$?
  [ "$status" -eq 2 ] || fail 'unknown options must exit with status 2'
fi

temporary_home=$(mktemp -d)
trap 'rm -rf "$temporary_home"' EXIT HUP INT TERM
HOME="$temporary_home" \
SHELL='/bin/zsh' \
PATH='/usr/bin:/bin' \
LITTLERIP_INSTALL_DIR="$temporary_home/.local/bin" \
  "$project_dir/install.sh" >/dev/null

[ -x "$temporary_home/.local/bin/littlerip" ] || fail 'installer must create an executable command'
installed_output=$("$temporary_home/.local/bin/littlerip")
[ "$installed_output" = 'littlerip' ] || fail 'installed command must run'
grep -Fq '# LittleRip CLI' "$temporary_home/.zshrc" || fail 'installer must update PATH when needed'

printf '%s\n' 'All tests passed.'
