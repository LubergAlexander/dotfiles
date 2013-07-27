#!/bin/zsh
rm $HOME/.vimrc
rm $HOME/.zshrc
rm $HOME/.tmux.conf
ln .vimrc $HOME/.vimrc
ln .zshrc $HOME/.zshrc
ln .tmux.conf $HOME/.tmux.conf
sudo ln copy-to-clipboard /usr/local/bin/copy-to-clipboard
sudo chmod a+x /usr/local/bin/copy-to-clipboard
