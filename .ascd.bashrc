# ------------------------------------------------------------------------
# Secret environment variables.

# Source credentials from untracked file if exists.
[ -r "$HOME/.creds.bashrc" ] && source "$HOME/.creds.bashrc"
# ------------------------------------------------------------------------
# Environment variables.

# Java settings.
if [ "$(uname -s)" = "Darwin" ]; then
  JAVA_HOME=$(/usr/libexec/java_home -v 21)
  export JAVA_HOME
fi

# Make tmux+NeoVim work over SSH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ASCENDING AWS profiles and regions.
export KXUE43_AWS_PROFILE_PREFIX="ascending"
export KXUE43_AWS_REGIONS="us-east-1"
# ------------------------------------------------------------------------
# Aliases.

alias gs='git status'
# ------------------------------------------------------------------------
# Functions.

sso-login() {
  aws sso login --sso-session sso-ascending
}
# ------------------------------------------------------------------------
