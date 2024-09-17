#!/opt/homebrew/bin/fish


# upgrade plug + upgrade plugins
nvim +PlugUpgrade +PlugUpdate +qa

brew update # update brew
brew upgrade # update packages

fisher update

mas upgrade

~/.tmux/plugins/tpm/bin/update_plugins all

mise plugin update

softwareupdate -i -a
