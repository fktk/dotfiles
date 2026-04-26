#!/bin/bash
# ~/.dotfilesにファイルを置いた場合
DOTFILES_DIR=$HOME/.dotfiles

ln -sf $DOTFILES_DIR/.bashrc $HOME/.bashrc

ln -sf $DOTFILES_DIR/tmuxp $HOME/.config
ln -sf $DOTFILES_DIR/nvim $HOME/.config
ln -sf $DOTFILES_DIR/tmux $HOME/.config
ln -sf $DOTFILES_DIR/yazi $HOME/.config
ln -sf $DOTFILES_DIR/tabby $HOME/.config
ln -sf $DOTFILES_DIR/ghostty $HOME/.config
ln -sf $DOTFILES_DIR/lazygit $HOME/.config
