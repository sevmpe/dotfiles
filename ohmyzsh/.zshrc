# Helper to find executables
exists()
{
    command -v ${1} > /dev/null 2>&1
}

# git clone a repo in user/reponame form to optional dir
clone-repo() {
    local repo="${1}"
    local dir="${2:-}"

    repo="https://github.com/${repo%.git}.git"

    [[ ! -z ${dir} ]] && mkdir -p "${dir}"

    echo "++ bootstrap: cloning ${repo} in ${dir}"

    git clone --depth=1 --recursive "${repo}" "${dir}"
}

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Install oh-my-zsh if not found
if [[ ! -d "${ZSH}" ]]; then
    clone-repo ohmyzsh/ohmyzsh "${ZSH}"
    clone-repo zsh-users/zsh-autosuggestions ${ZSH}/custom/plugins/zsh-autosuggestions
    clone-repo zsh-users/zsh-syntax-highlighting ${ZSH}/custom/plugins/zsh-syntax-highlighting
    # fix permissions or ohmyzsh does not load plugins
    chmod -R g-w,o-w "${ZSH}"
fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="avit"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  docker
  git
  python
  autojump
  extract
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias ssh256='TERM=xterm-256color ssh'

# echo "Adding ASHS (fastashs) to the path:"
# export ASHS_ROOT=$HOME/Source/external/ashs

# echo "Adding user's bin/ to path"
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/abin
export PATH=$PATH:/opt/bin:/opt/app

CONDA_FOUND=0
# Conda
if [[ -d /opt/conda ]]; then
    # should that be source /opt/conda/bin/activate
    # instead of just export the conda bin path?
    . "/opt/conda/etc/profile.d/conda.sh"
    CONDA_FOUND=1
elif [[ -d $HOME/miniconda ]]; then
    # export PATH="$HOME/conda/bin:$PATH"
    . "$HOME/miniconda/etc/profile.d/conda.sh"
    CONDA_FOUND=1
fi
if [[ ${CONDA_FOUND} == 1 ]]; then
    conda activate base
fi
# alias for common environments
alias sdk="conda activate sdk"

export WORK=/mnt/work/$(id -un)

# Some locale settings, perhaps they should go in
# ~/.pam_environment

# export LANG=de_DE.UTF-8
# export LC_ALL=de_DE.UTF-8
# export LC_MESSAGES=POSIX


# less setup to use highlight
if exists highlight; then
    export LESSOPEN="| $(which highlight) --out-format=xterm256 --line-numbers --quiet --force --style=molokai %s"
    export LESS=" -R "
    export PAGER="less"
    # alternative to cat using highligh
    alias hicat="highlight --out-format=xterm256 --line-numbers --quiet --force --style=molokai $1"
fi

# Poor man's um, personal notes
# new note
nnote() {
    mkdir -p ~/Documents/notes
    local notefile=~/Documents/notes/$(date +"%d-%m-%Y").md
    echo "# $(date +'%d.%m.%Y')" > ${notefile}
    $EDITOR ${notefile}
}
# edit daily note
enote() {
    ${EDITOR} ~/Documents/notes/${1}.md
}
noteless() {
    pandoc -s -f markdown -t man ${1} | groff -T utf8 -man | less
}
notehtml() {
    local htmlfile=/tmp/${${1##*/}%.md}.html
    pandoc -s -f markdown -t html5 ${1} -o ${htmlfile} && xdg-open ${htmlfile}
}
# show note
snote() { noteless ~/Documents/notes/${1}.md }
# html note
hnote() { notehtml ~/Documents/notes/${1}.md }
# liss notes
lnote() { ls -l ~/Documents/notes | column -t }

# FZF
# github.com/junegunn/fzf
fzv () {
    # fuzzy vim: use fzf to call vim/nvim
    local prevops
    prevops='[[ $(file --mime {}) =~ binary ]] &&
        echo {} is a binary file ||
        (highlight -O xterm256 --line-numbers --style=molokai {} ||
         cat{})2> /dev/null |head -500'
    nvim $(fzf --preview "$prevops")
}
# Use fd instead of find if available
# In Ubuntu the binary is called `fdfind`
if exists fdfind; then
    export FZF_DEFAULT_COMMAND='fdfind --type f'
    export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
    export FZF_ALT_C_COMMAND='fdfind --type d --follow'
fi
# some default options
export FZF_DEFAULT_OPTS='--height 60% --reverse --preview-window up'
# CTRL-R options: add preview
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap --bind '?:toggle-preview'"
# ALT-C options: show tree preview
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"
[[ -f ~/.fzf.zsh ]] && . ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/jose/google-cloud-sdk/path.zsh.inc' ]; then . '/home/jose/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/jose/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/jose/google-cloud-sdk/completion.zsh.inc'; fi