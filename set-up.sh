#!/usr/bin/env bash

set -eu -o pipefail

_log_error() {
  if [[ -t 2 ]]; then
    printf "\033[31m%s\033[0m\n" "$1" >&2
  else
    echo "$1" >&2
  fi
}

_log_info() {
  if [[ -t 1 ]]; then
    printf "\033[36m%s\033[33m%s\033[36m.\033[0m\n" "$@"
  else
    echo "${*}"
  fi
}

# Create symlinks in source_dir and point them to actual files in sink_dir.
# Args:
#   $1: source_dir
#   $2: sink_dir
#   $3: name of the array variable that holds base names
# Returns: None
_link_files() {
  local -n base_names="$3"

  local name target_now

  for name in "${base_names[@]}"; do
    if [[ -L "$1/$name" ]]; then
      target_now="$(readlink -f "$1/$name")"

      if [[ "$2/$name" -ef "$target_now" ]]; then
        # If already correctly symlinked, continue.
        continue
      else
        _log_info "$name is symlinked to $target_now. Removing"

        unlink "$1/$name"
      fi
    elif [[ -f "$1/$name" ]]; then
      # If the ln target already exists as a regular file, remove it.
      _log_info "Removing existing file $name"

      rm "$1/$name"
    fi

    # If execution reaches here, create the correct symlink.
    ln -s "$2/$name" "$1/$name"

    _log_info "$name has been correctly symlinked"
  done
}

main() {
  # Make necessary directories first.
  mkdir -p "$HOME/.config/ghostty"
  mkdir -p "$HOME/.config/bat"

  # shellcheck disable=SC2034 # used via nameref
  local -a tracked=(
    .bash_logout
    .bash_profile
    .bashrc
    .inputrc
    .gitconfig
    .vimrc
    .gvimrc
    .tmux.conf
    .config/ghostty/config
    .config/bat/config
  )

  _log_info "Installing from $KXUE43_DOTFILES_DIR"

  _link_files "$HOME" "$KXUE43_DOTFILES_DIR" "tracked"

  local local_bin="$HOME/.local/bin"

  mkdir -p "$local_bin"

  local -a binaries

  # shellcheck disable=SC2034 # used via nameref
  mapfile -t binaries < <(ls -1 "$KXUE43_DOTFILES_DIR/bin")

  _link_files "$local_bin" "$KXUE43_DOTFILES_DIR/bin" "binaries"

  mapfile -t binaries < <(find "$local_bin" -type l)

  # Clean up symlinks in ~/.local/bin
  for name in "${binaries[@]}"; do
    if [[ ! -x "$(readlink -f "$name")" ]]; then
      _log_info "Script $name should no longer exist. Removing"

      unlink "$name"
    fi
  done

  # Disable Git commit signing in devcontainer.
  if [[ "$(whoami)" == "vscode" ]]; then
    cat >"HOME/.gitconfig.override" <<'EOF'
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
