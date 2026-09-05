dotfiles
========

Configs managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
package directory mirrors `$HOME`. Run the commands below from the repository root.

# Prerequisites

- **Neovim 0.12 or newer**, Git, a C compiler, Go, Node.js/npm, `tree-sitter-cli`,
  and `uv`. Mason installs the configured language servers and debug adapters;
  it needs these language runtimes and archive tools, not just Neovim.
- The Neovim Python provider is explicitly provisioned at
  `~/.virtualenvs/neovim3/bin/python`; a system `pynvim` package is not a substitute.
- Exact Ghostty appearance requires the licensed **BerkeleyMono Nerd Font** family
  at size 17. Obtain Berkeley Mono from [its publisher](https://usgraphics.com/products/berkeley-mono)
  and install your licensed, appropriately patched copy manually. No proprietary
  font is downloaded by this repository. Homebrew and Arch lists include Hack Nerd
  Font as a free alternative; select `Hack Nerd Font` in Ghostty if desired.
- Ghostty uses its native `xterm-ghostty` capabilities, and tmux uses
  `tmux-256color`. Install the matching terminfo on remote hosts too rather than
  overriding `TERM` to impersonate another terminal. tmux 3.7+ follows terminal
  light/dark appearance; older versions use the static dark theme.

# Fresh machine setup (macOS)

```sh
# 1. Install Apple's Command Line Tools (compiler, make, archive/system utilities).
xcode-select --install

# 2. Install Homebrew from https://brew.sh and initialize its shell environment.
# Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel Macs use /usr/local/bin/brew instead.
brew bundle --file=homebrew/.Brewfile

# 3. Install the licensed font manually, then follow "Install the configs" below.
```

The Brewfile includes desktop applications as well as CLI dependencies; review it
before installation. `tlrc` provides the maintained `tldr` command. macOS already
provides `pbcopy`, `open`, SSH, `tar`, `gzip`, and `unzip`. Ghostty uses native
login-shell discovery, without a custom launch wrapper. Register the output of
`printf '%s\n' "$(brew --prefix)/bin/zsh"` in `/etc/shells` using `sudoedit /etc/shells`
if it is not already listed, then run `chsh -s "$(brew --prefix)/bin/zsh"`.
This selects `/opt/homebrew/bin/zsh` on Apple Silicon or `/usr/local/bin/zsh` on
Intel. tmux also selects the installed Homebrew Zsh explicitly.

After installing the configs, review `defaults.sh` and run `./defaults.sh` to apply
its macOS preferences. This is separate from Stow and is not an Arch setup step.

# Fresh machine setup (Arch Linux)

```sh
# Official repositories only; never perform a partial Arch upgrade.
sudo pacman -Syu --needed - < arch_pkglist.txt

# Initialize the database used by the command-not-found shell plugin.
sudo pkgfile --update
sudo systemctl enable --now pkgfile-update.timer

# LLM is a Python CLI, installed in its own uv-managed tool environment.
uv tool install llm

# Install a licensed font manually or select the packaged Hack Nerd Font.
# Then follow "Install the configs" below.
```

The package list targets official x86_64 Arch repositories, not Homebrew formula
names or AUR packages. It includes `eza`, `kubectl`, `helm`, `kubectx`, `krew`,
`kind`, `azure-cli`, and Docker tooling. `tealdeer` provides `tldr`; `procps-ng`
provides `watch`. `ghostty-terminfo` provides `xterm-ghostty`, and `ncurses` provides
`tmux-256color`. `wl-clipboard` (Wayland), `xclip` (X11), and `xdg-utils` supply
clipboard/opening backends. `ttf-hack-nerd` is the free font fallback. These names
are listed in the [official Arch package database](https://archlinux.org/packages/).

`topgrade` is available separately in the [AUR](https://aur.archlinux.org/packages/topgrade),
not in the official package list: review its PKGBUILD before building it with your
preferred AUR workflow. Docker daemon setup, desktop sessions, and SSH-agent services
are machine-specific; they are not enabled by Stow. The shell preserves an inherited
SSH agent and only selects `$XDG_RUNTIME_DIR/ssh-agent.socket` when that socket exists.
macOS appearance detection is not needed on Linux: `bat` defaults to `gruvbox-dark`
unless `BAT_THEME` is set explicitly. Run `chsh -s /usr/bin/zsh` to select the
installed Zsh as the login shell used by Ghostty; tmux also uses installed Zsh.

# Install the configs (both platforms)

Stow refuses conflicting unmanaged files. Back up and reconcile any existing config
before installing; do not use `--adopt` to overwrite repository files accidentally.
In particular, the existing prompt is now tracked at `zsh/.p10k.zsh`. To preserve an
unmanaged `~/.p10k.zsh` before replacing it with a Stow link:

```sh
if [ -e "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
  backup_dir=$(mktemp -d "$HOME/.dotfiles-backup.XXXXXX")
  mv "$HOME/.p10k.zsh" "$backup_dir/.p10k.zsh"
  printf 'Original prompt preserved in %s\n' "$backup_dir/.p10k.zsh"
fi

# Preview all package symlinks, resolve any other conflicts, then install them.
stow --simulate --verbose --target="$HOME" --restow */
make all

# Provision pynvim without activating a venv or deleting existing environments.
make python-host
```

`make all` only restows every top-level package into `$HOME`, including Homebrew's
Brewfile on either platform. It does **not** install OS packages, configure the login
shell, provision Python, or apply macOS preferences. Stow may fold an entire directory
into a symlink when no existing directory prevents it. `make delete` removes these
managed symlinks, not installed packages or unrelated files.

`make python-host` and the interactive `update_neovim_venvs` helper use the same
provisioner: create only the missing `neovim3` environment using `uv`, then upgrade
`pynvim` only inside it. An invalid or broken existing environment is refused, not
deleted; move that exact directory to a backup and rerun the command if rebuilding
is necessary. Sibling virtual environments are untouched.

The tracked Powerlevel10k config preserves the existing colors and single-line layout,
with transient prompt `always` and instant prompt `quiet`. Edit `~/.p10k.zsh` (the
Stow link) for prompt settings, not duplicate variables in `.zshrc`. The standard
instant-prompt preamble stays near the top of `.zshrc`; any initialization requiring
console input must precede it. On a fresh machine Zinit downloads shell plugins on
first interactive startup, TPM bootstraps tmux plugins on first tmux startup, and
Neovim installs its plugins using the committed `lazy-lock.json`. Network access is
required. Use Lazy's restore operation to return to the committed plugin snapshot;
updating plugins intentionally changes that snapshot.

On an existing installation, refresh **only the aliases snippet** once after deployment
from an initialized interactive Zsh: `zinit update "$HOME/.aliases.zsh"`. Then open
a new shell so removed aliases disappear too. Local snippet loading/caching remains
unchanged; do not refresh, move, or alter the untracked secrets file as part of setup.

The optional Claude Code editor integration requires the official
[Claude Code CLI](https://code.claude.com/docs/en/setup) and its own authentication;
install it using the supported platform instructions before using those mappings.
LM Studio is optional; its CLI path is included only when `$HOME/.lmstudio/bin` exists.

# Machine-specific Git identity

Create or edit `~/.gitconfig.local` without overwriting existing machine settings:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
[credential "https://github.com"]
    helper =
    helper = !/absolute/path/to/gh auth git-credential
[credential "https://gist.github.com"]
    helper =
    helper = !/absolute/path/to/gh auth git-credential
```

Replace `/absolute/path/to/gh` with `command -v gh` output. Homebrew runs Git with a
sanitized `PATH`, so this helper must use an absolute path. Authenticate with `gh auth
login` separately; credentials and local identity are not tracked here.

# Maintenance

- `uv-tools-upgrade` upgrades only tools installed with `uv tool`, not global pip
  packages, project dependencies, or the Neovim host. Use `make python-host` for the host.
- `topgrade` runs broad updates (packages, editor plugins, and more); review its scope
  and `topgrade/.config/topgrade.toml` before running it. It is not the reproducible
  plugin-restore path.
- `make all` restows configs after repository changes; `make delete` unstows them.

Optional Gemini CLI installations use the maintained npm package
`@google/gemini-cli` (see [Google's installation instructions](https://geminicli.com/docs/get-started/installation/)):
`npm install -g @google/gemini-cli`. This is separate from Homebrew Bundle and from
`uv-tools-upgrade`; maintain it with npm without resetting existing authentication.
