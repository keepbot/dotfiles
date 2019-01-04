#!/usr/bin/env bash
# Test for interactiveness
[[ $- == *i* ]] || return

# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

for file in ${HOME}/.bash/autoload/*; do
  source ${file}
done

# Set Prompt
# [[ -f $HOME/.bash/git-prompt.sh ]]          && source ~/.bash/git-prompt.sh
# [[ -f $HOME/.bash/prompt.sh ]]              && source ~/.bash/prompt.sh

#Import Rust env
[[ -f $HOME/.cargo/env ]]                   && source $HOME/.cargo/env

# Auto .env
#[[ -f $HOME/.bash/venv.sh ]]                && source ~/.bash/venv.sh

[[ -f $HOME/.localenv ]]                    && source ~/.localenv
