#!/usr/bin/env bash

set -eu -o pipefail

main() {
  # Make necessary directories first.
  mkdir -p "$HOME/.config/ghostty"
  mkdir -p "$HOME/.config/bat"

  if ! [ -r "$HOME/.creds.bashrc" ]; then
    touch "$HOME/.creds.bashrc"
  fi

  local -a tracked=(
    .bash_logout
    .bash_profile
    .bashrc
    .inputrc
    .fns.bashrc
    .kxue43.bashrc
    .ascd.bashrc
    .gitconfig
    .vimrc
    .gvimrc
    .tmux.conf
    .config/ghostty/config
    .config/bat/config
  )

  # Get the directory where this script is located
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "Installing dotfiles from $dotfiles_dir"

  local name
  for name in "${tracked[@]}"; do
    # If the ln target already exists as a regular file, remove it.
    [ -f "$HOME/$name" ] && rm "$HOME/$name"

    # This is a no-ops if the target is already a symlink.
    ln -s "$dotfiles_dir/$name" "$HOME/$name"
  done

  local prefix="$HOME/.local/bin"

  mkdir -p "$prefix"

  for name in ./bin/*; do
    name="$(basename "$name")"

    # If the ln target already exists as a regular file, remove it.
    [ -f "$prefix/$name" ] && rm "$prefix/$name"

    # This is a no-ops if the target is already a symlink.
    ln -s "$dotfiles_dir/bin/$name" "$prefix/$name"
  done

  local -a binaries
  mapfile -t binaries < <(find "$prefix" -type l)

  # Clean up symlinks in ~/.local/bin
  for name in "${binaries[@]}"; do
    if ! [ -x "$(readlink "$name")" ]; then
      unlink "$name"
    fi
  done

  # Disable Git commit signing in devcontainer.
  if [ "$(whoami)" = "vscode" ]; then
    cat >"$HOME/.gitconfig.override" <<'EOF'
[user]
	name = kxue43
	email = xueke.kent@gmail.com
[commit]
	gpgsign = false
[tag]
	gpgSign = false
EOF
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
