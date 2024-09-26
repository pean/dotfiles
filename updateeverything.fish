#!/opt/homebrew/bin/fish


# upgrade plug + upgrade plugins
nvim +PlugUpgrade +PlugUpdate +qa

brew update # update brew
brew upgrade # update packages

fisher update

mas upgrade

~/.tmux/plugins/tpm/bin/update_plugins all

mise plugin update

pip3 install --upgrade (pip3 list | awk 'NR>2 {print $1}')
pip install --upgrade (pip list | awk 'NR>2 {print $1}')

softwareupdate -i -a
