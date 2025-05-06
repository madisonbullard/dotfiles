export PATH=$HOME/bin/.local/scripts:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM=$HOME/.config/zsh/custom
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  nvm
  vi-mode
  aws
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

source $ZSH/oh-my-zsh.sh

alias zshrc="windsurf ~/.zshrc"
alias p="pnpm"
alias pu="p up --interactive --latest"
alias pi="p i"

alias python="python3"
alias pip="pip3"

alias b="bun"
alias bi="bun install"
alias buw="bunx npm-check-updates -ws --root --format group -i"

alias nvim="$HOME/bin/nvim-macos-arm64/bin/nvim"

alias cd.="cd .."

login() {
  aws sso login --profile $1
}


# Created by `pipx` on 2023-05-25 18:58:20
export PATH="$PATH:/Users/madisonbullard/.local/bin"

# *** PROMPT FORMATTING ***

# Echoes a username/host string when connected over SSH (empty otherwise)
ssh_info() {
  [[ "$SSH_CONNECTION" != '' ]] && echo "%(!.%{$fg[red]%}.%{$fg[yellow]%})%n%{$reset_color%}@%{$fg[green]%}%m%{$reset_color%}:" || echo ""
}

# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local AHEAD="%{$fg[red]%}⇡ NUM%{$reset_color%}"
  local BEHIND="%{$fg[cyan]%}⇣ NUM%{$reset_color%}"
  local MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
  local UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
  local MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
  local STAGED="%{$fg[green]%}●%{$reset_color%}"

  local -a DIVERGENCES
  local -a FLAGS

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    FLAGS+=( "$MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=( "$MODIFIED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  local -a GIT_INFO
  GIT_INFO+=( "%{$fg[cyan]%}±" )
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  GIT_INFO+=( "%{$fg[cyan]%}$GIT_LOCATION%{$reset_color%}" )
  echo "${(j: :)GIT_INFO}"

}

# Use ❯ as the non-root prompt character; # for root
# Change the prompt character color if the last command had a nonzero exit code
PS1="
\$(ssh_info)%{$fg[magenta]%}%~%u \$(git_info)
%(?.%{$fg[blue]%}.%{$fg[red]%})%(!.#.❯)%{$reset_color%} "

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

PATH=~/.console-ninja/.bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# sst
export PATH=/Users/madisonbullard/.sst/bin:$PATH

# bun completions
[ -s "/Users/madisonbullard/.bun/_bun" ] && source "/Users/madisonbullard/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# -----------------------------------------------------------------------------
# AI-powered Git Commit Function
# Copy paste this gist into your ~/.bashrc or ~/.zshrc to gain the `gcm` command. It:
# 1) gets the current staged changed diff
# 2) sends them to an LLM to write the git commit message
# 3) allows you to easily accept, edit, regenerate, cancel
# But - just read and edit the code however you like
# the `llm` CLI util is awesome, can get it here: https://llm.datasette.io/en/stable/

function aic {
    # Function to generate commit message
    function generate_commit_message {
        git diff --cached | llm "
Below is a diff of all staged changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`
Write concise, informative commit messages: 
Start with a summary in imperative mood. Explain the 'why' behind changes. 
Keep the summary under 100 characters. If the changes are lengthy and warrant further explanation, use bullet points for multiple changes, but try to avoid that if possible. 
Avoid using the word 'refactor'. Instead, explain what was done and reference related issues or tickets. 
What you write will be passed to git commit -m.
"
    }

    # Function to read user input compatibly with both Bash and Zsh
    function read_input {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    while true; do
        echo -e "\nProposed commit message:"
        echo "$commit_message"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

# Added by Windsurf
export PATH="/Users/madisonbullard/.codeium/windsurf/bin:$PATH"
