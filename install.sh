#!/bin/bash
# ~/.dotfilesにファイルを置いた場合
DOTFILES_DIR=$HOME/.dotfiles

ln -sf $DOTFILES_DIR/nvim $HOME/.config/nvim
ln -sf $DOTFILES_DIR/tmux $HOME/.config/tmux
ln -sf $DOTFILES_DIR/yazi $HOME/.config/yazi
