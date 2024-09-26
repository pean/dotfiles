#!/opt/homebrew/bin/fish

# upgrade nvim plugins
nvim --headless "+Lazy! sync " +qa

brew update # update brew
brew upgrade # update packages

fisher update

~/.tmux/plugins/tpm/bin/update_plugins all

mise plugin update

pip3 install --upgrade (pip3 list | awk 'NR>2 {print $1}')
pip install --upgrade (pip list | awk 'NR>2 {print $1}')

mas upgrade

softwareupdate -i -a
