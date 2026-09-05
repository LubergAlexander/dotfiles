.PHONY: all delete python-host

all:
	stow --verbose --no-folding --target="$$HOME" --restow */

delete:
	stow --verbose --no-folding --target="$$HOME" --delete */

# Use the same narrowly scoped provisioner as the interactive shell helper.
python-host:
	zsh -f -c 'source ./zsh/.aliases.zsh; update_neovim_venvs'
