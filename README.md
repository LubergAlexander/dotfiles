dotfiles
========

Configs managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory mirrors `$HOME` and gets symlinked into place.

# Fresh machine setup (macOS)

```sh
# 1. Install Homebrew (https://brew.sh), then all packages
brew bundle --file=~/code/dotfiles/homebrew/.Brewfile

# 2. Symlink all configs into $HOME
make all

# 3. Apply macOS system preferences (key repeat, dock, finder, ...)
./defaults.sh

# 4. Machine-specific git identity (not tracked in this repo)
cat > ~/.gitconfig.local <<EOF
[user]
	name = Your Name
	email = you@example.com
EOF
```

# Maintenance

- `topgrade` — updates everything (brew, casks, nvim plugins, ...); config in `topgrade/`
- `make delete` — remove all symlinks
- `arch_pkglist.txt` — package list for the Arch Linux machine
