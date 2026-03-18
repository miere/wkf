#!/usr/bin/env bash

# install gum
brew install gum

# install skate
brew tap charmbracelet/tap && brew install charmbracelet/tap/skate

# install vim goodies
brew install macvim

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ -f ~/.vimrc ]; then
  echo "Creating a backup of your ~/.vimrc..."
  mv ~/.vimrc ~/.vimrc.bkp.$(date +%s)
fi

cat <<EOF > ~/.vimrc
set macmeta
syntax enable

call plug#begin()
Plug 'sheerun/vim-polyglot'   " syntax for 100+ languages
call plug#end()

EOF
