# -----------------------------------------------------------------------
# Locate dotfiles directory
KXUE43_DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

export KXUE43_DOTFILES_DIR
# -----------------------------------------------------------------------
# Source personal library functions.
source "$KXUE43_DOTFILES_DIR/.lib.bashrc"
# -----------------------------------------------------------------------
# Initialization

_kxue43_bash_init
trap '_kxue43_bash_postinit; trap - RETURN' RETURN
# ------------------------------------------------------------------------
# Environment variables

# Make GPG correctly cache passphrase on VS Code terminal
GPG_TTY=$(tty)
export GPG_TTY

# C-x C-e invokes Vim on the current command line.
# VSCode integrated terminal has some problem with NeoVim.
export EDITOR=vim
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
alias clean-aws-cache="unset AWS_SESSION_TOKEN && unset AWS_SECRET_ACCESS_KEY && unset AWS_ACCESS_KEY_ID && unset AWS_CREDENTIAL_EXPIRATION && rm -rf ~/.aws/toolkit-cache && rm -rf ~/.aws/sso/cache && rm -rf ~/.aws/cli/cache && rm -rf ~/.aws/boto/cache"
alias clean-aws-env="unset AWS_SESSION_TOKEN && unset AWS_SECRET_ACCESS_KEY && unset AWS_ACCESS_KEY_ID && unset AWS_REGION && unset AWS_DEFAULT_REGION && unset AWS_PROFILE && unset AWS_CREDENTIAL_EXPIRATION"
alias gci='aws sts get-caller-identity'
alias ls-path='printenv PATH | tr ":" "\n"'
alias nvconfp='pushd ~/.config/nvim >/dev/null && git pull && popd >/dev/null'
# ------------------------------------------------------------------------
# Interactive functions
source "$KXUE43_DOTFILES_DIR/.fns.bashrc"
# ------------------------------------------------------------------------
