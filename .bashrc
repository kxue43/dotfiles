# -----------------------------------------------------------------------
# Source private functions.
source "$HOME/.fns.bashrc"
# -----------------------------------------------------------------------
_kxue43_set_path

_kxue43_activate_fnm

_kxue43_enable_completion

_kxue43_shell_integration

_kxue43_set_man_pager
# ------------------------------------------------------------------------
# Readline settings

# C-x C-e invokes NeoVim on the current command line.
export EDITOR=nvim
# ------------------------------------------------------------------------
# Aliases

alias ls='ls --color=auto'
alias gproj='cd ~/projects'
alias gtemp='cd ~/temp'
alias glearn='cd ~/learning'
alias gascd='cd ~/ascending'
alias gdump='cd ~/temp/dump'
alias rdump='pushd ~/temp >/dev/null ; rm -rf dump && mkdir dump ; popd >/dev/null'
alias venvact='. .venv/bin/activate'
alias pea='eval $(poetry env activate)'
alias pue='poetry config --local virtualenvs.in-project true && poetry env use $(pyenv which python)'
alias ssp='python -c "import site;print(site.getsitepackages())"'
alias clean-aws-cache="unset AWS_SESSION_TOKEN && unset AWS_SECRET_ACCESS_KEY && unset AWS_ACCESS_KEY_ID && unset AWS_CREDENTIAL_EXPIRATION && rm -rf ~/.aws/toolkit-cache && rm -rf ~/.aws/sso/cache && rm -rf ~/.aws/cli/cache && rm -rf ~/.aws/boto/cache"
alias clean-aws-env="unset AWS_SESSION_TOKEN && unset AWS_SECRET_ACCESS_KEY && unset AWS_ACCESS_KEY_ID && unset AWS_REGION && unset AWS_DEFAULT_REGION && unset AWS_PROFILE && unset AWS_CREDENTIAL_EXPIRATION"
alias gci='aws sts get-caller-identity'
alias ls-path='printenv PATH | tr ":" "\n"'
alias nvconfp='pushd ~/.config/nvim >/dev/null && git pull && popd >/dev/null'
# ------------------------------------------------------------------------
# Environment variables

# Make GPG correctly cache passphrase on VS Code terminal
GPG_TTY=$(tty)
export GPG_TTY
# ------------------------------------------------------------------------
# Functions

list-all() {
  local -a executables aliases

  mapfile -t executables < <(grep "^[a-zA-Z0-9-]\+() {" "$HOME/.bashrc")

  mapfile -t aliases < <(grep "^alias [a-zA-Z0-9-]\+=" "$HOME/.bashrc")

  local prefix

  case "$(hostname)" in
  Kes-MacBook-Pro.*)
    prefix=ascd
    ;;
  LM-*)
    prefix=gd
    ;;
  *)
    prefix=kxue43
    ;;
  esac

  if [ -r "$HOME/.${prefix}.bashrc" ]; then
    mapfile -t -O "${#executables[@]}" executables < <(grep "^[a-zA-Z0-9-]\+() {" "$HOME/.${prefix}.bashrc")

    mapfile -t -O "${#executables[@]}" aliases < <(grep "^alias [a-zA-Z0-9-]\+=" "$HOME/.${prefix}.bashrc")
  fi

  executables=("${executables[@]%() \{}")

  aliases=("${aliases[@]%%=*}")
  aliases=("${aliases[@]#alias }")

  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

  mapfile -t -O "${#executables[@]}" executables < <(ls -1 "$dotfiles_dir/bin/")

  printf "%s\n" "${executables[@]}" "${aliases[@]}" | sort | column -c "$(tput cols)" -x
}

tl() {
  tmux list-sessions -F '#{session_name}: #{session_windows}win'
}

dotfp() {
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}")")" && pwd)"

  echo "Pulling dot-file changes into $dotfiles_dir"

  pushd "$dotfiles_dir" >/dev/null || return 1

  git pull

  popd >/dev/null || return 1
}

set-aws-region() {
  local region

  if [ -n "${1:+x}" ]; then
    region=$1
  else
    region=$(_kxue43_prompt_aws_region "$KXUE43_AWS_REGIONS")
  fi

  export AWS_DEFAULT_REGION=$region

  export AWS_REGION=$region
}

ls-aws-env() {
  printenv | grep '^AWS'
}

use-role-profile() {
  if [ -n "${1:+x}" ]; then
    export AWS_PROFILE=$1

    return 0
  fi

  AWS_PROFILE=$(_kxue43_prompt_aws_profile "$KXUE43_AWS_PROFILE_PREFIX")
  export AWS_PROFILE
}

set-role-env() {
  local profile

  if [ -n "${1:+x}" ]; then
    profile=$1
  else
    profile=$(_kxue43_prompt_aws_profile "$KXUE43_AWS_PROFILE_PREFIX")
  fi

  eval "$(aws configure export-credentials --format env --profile "$profile")"

  unset AWS_PROFILE
}

glo() {
  git log --oneline "$@"
}

gsh() {
  git show --name-only "$@"
}

my-diff() {
  git diff --no-index "$1" "$2"
}

gtc() {
  local profile=coverage.out

  go test -race -coverprofile=${profile} "${1:-./...}"

  go tool cover -html=${profile}
}

init-devcon-files() {
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

  if ! [ -d "$dotfiles_dir/.devcontainer" ]; then
    echo "The $dotfiles_dir/.devcontainer/ folder does not exist." >&2

    return 1
  fi

  echo "Creating .devcontainer/ folder in the current working directory."

  cp -R "$dotfiles_dir/.devcontainer/" ./.devcontainer/
}

mcpgw-update-key() {
  local token
  token="$(pbpaste)"

  local backup_dir="$HOME/temp/save/claude"
  ! [[ -d "$backup_dir" ]] && mkdir -p "$backup_dir"

  local backup_file="$backup_dir/.claude.json.bak"

  [[ -f "$backup_file" ]] && rm "$backup_file"

  mv "$HOME/.claude.json" "$backup_file"

  TOKEN="${token}" jq '.mcpServers.mcpgw.headers.Authorization = "Bearer " + env.TOKEN' --indent 2 "$backup_file" >"$HOME/.claude.json"
}

rm-cdk-images() {
  local tags
  mapfile -t tags < <(docker images --filter "reference=cdkasset-*:latest" --format "{{.Repository}}:{{.Tag}}")

  if ((${#tags[@]} == 0)); then
    echo "No existing CDK asset images."

    return 0
  fi

  docker image rm "${tags[@]}"

  mapfile -t tags < <(docker images --filter "reference=*.amazonaws.com/cdk-hnb659fds-*:*" --format "{{.Repository}}:{{.Tag}}")

  if ((${#tags[@]} > 0)); then
    docker image rm "${tags[@]}"
  fi
}

rm-docker-images() {
  local tags
  mapfile -t tags < <(docker images --format "{{.Repository}}:{{.Tag}}" | fzf -m)

  if ((${#tags[@]} == 0)); then
    echo "No image selected."

    return 0
  else
    printf "\033[36m%s\033[0m\n" "The following images are selected:"
    printf "\033[36m%s\033[0m\n" "${tags[@]}"
    printf "\n"
  fi

  docker image rm "${tags[@]}"
}

if [ "$(uname -s)" = "Darwin" ]; then
  ls-jdk() {
    /usr/libexec/java_home -V
  }

  set-jdk() {
    local jdk_version

    jdk_version=$(_kxue43_prompt_jdk_version)

    JAVA_HOME=$(/usr/libexec/java_home -v "$jdk_version")
    export JAVA_HOME
  }

  user-query() {
    dscl . -read "$HOME" UniqueID PrimaryGroupID NFSHomeDirectory UserShell
  }
fi
# ------------------------------------------------------------------------
# Source env-specific bashrc file.
_kxue43_source_env_bashrc
# ------------------------------------------------------------------------
