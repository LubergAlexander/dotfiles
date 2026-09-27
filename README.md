dotfiles
========

macOS and Arch Linux configs, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Every top-level directory is a package that mirrors `$HOME`. One Gruvbox theme follows
the system light/dark setting across Ghostty, tmux, Neovim, Zed, fzf, bat, and omp.

| Package | Contents |
| --- | --- |
| `zsh` | `.zshrc` (zinit, fzf, zoxide), `.aliases.zsh`, Powerlevel10k prompt |
| `tmux` | `tmux.conf`, Gruvbox themes, copy-mode opener script |
| `nvim` | single-file `init.lua` and `lazy-lock.json` |
| `ghostty` | terminal config and Gruvbox themes |
| `zed` | settings, Neovim-style keymap, debug scenarios |
| `git` | `.gitconfig` (delta, zdiff3); identity lives in `~/.gitconfig.local` |
| `omp` | agent config and LSP settings |
| `yazi`, `topgrade` | small overrides |
| `homebrew` | `.Brewfile` |

Not stowed: `defaults.sh` (macOS preferences) and `arch_pkglist.txt` /
`arch_aur_pkglist.txt` (Arch packages).

# Setup

## 1. Packages

**macOS**

```sh
xcode-select --install                       # compiler, make, archive tools
# Install Homebrew from https://brew.sh, then:
eval "$(/opt/homebrew/bin/brew shellenv)"    # Intel: /usr/local/bin/brew
brew bundle --file=homebrew/.Brewfile        # third-party taps are marked trusted: true
```

The Brewfile includes desktop apps; review it first. To make Homebrew's Zsh the
login shell, add `$(brew --prefix)/bin/zsh` to `/etc/shells` and run `chsh -s` with it.

**Arch Linux**

```sh
sudo pacman -Syu --needed - < arch_pkglist.txt
yay -S --needed - < arch_aur_pkglist.txt     # omp, topgrade, herdr; review PKGBUILDs
uv tool install llm
sudo pkgfile --update && sudo systemctl enable --now pkgfile-update.timer
chsh -s /usr/bin/zsh
```

Docker, desktop sessions, and the SSH agent are machine-specific and not set up
here. The shell uses `$XDG_RUNTIME_DIR/ssh-agent.socket` only if no agent is inherited.

**Font.** Ghostty and Zed use the licensed
[Berkeley Mono](https://usgraphics.com/products/berkeley-mono) Nerd Font at 17 pt,
installed manually. Both fall back to the free Hack Nerd Font from the package lists.

## 2. Configs

Stow refuses to replace existing files. Preview, move conflicts aside (don't use
`--adopt`, which overwrites the repository), then link:

```sh
stow --simulate --verbose --no-folding --target="$HOME" --restow */
make all            # link every package
make python-host    # create ~/.virtualenvs/neovim3 with pynvim for Neovim
```

`--no-folding` links files, never directories, so files that apps create stay out
of the repository. `make delete` removes the links.

On first start, zinit installs shell plugins, TPM installs tmux plugins, and Neovim
installs plugins from `lazy-lock.json` plus Mason's servers, formatters, and
debuggers. This needs network access.

## 3. Machine-local files

These are untracked:

- `~/.gitconfig.local`: identity and GitHub credentials.

  ```gitconfig
  [user]
      name = Your Name
      email = you@example.com
  [credential "https://github.com"]
      helper =
      helper = !/opt/homebrew/bin/gh auth git-credential
  [credential "https://gist.github.com"]
      helper =
      helper = !/opt/homebrew/bin/gh auth git-credential
  ```

  Use the absolute path from `command -v gh`; Homebrew runs Git with a reduced
  `PATH`. Never use `git config --global` or `gh auth setup-git`: `~/.gitconfig` is
  a Stow link, so they write into the repository. Use
  `git config --file ~/.gitconfig.local` instead.
- `~/.secrets.env`: environment secrets, sourced by the shell. Keep it at mode `600`.

## 4. macOS preferences

Review and run `./defaults.sh` (keyboard repeat, Dock, Finder, screenshots, and more).

# Shell

- **Pickers:** `Ctrl+T` files (bat preview), `Ctrl+R` history, `Alt+C` directories
  (eza preview), and fzf-tab for completion. Inside tmux they open as 80% × 60% popups.
- **Keys:** `Esc Esc` prefixes the line with sudo; `Esc .` inserts the last argument.
- **Aliases:** eza for `ls`/`ll`/`tree`, `vim` → nvim, `gpm` (update main, then
  return), plus Oh My Zsh git, kubectl, helm, and docker aliases.
- `bat` picks `gruvbox-dark` or `gruvbox-light` from the terminal background.
- Prompt settings live in `~/.p10k.zsh`. Anything that reads console input must go
  above the instant-prompt block at the top of `.zshrc`.

Keep `FZF_DEFAULT_OPTS` appearance-only: extrakto inherits it, so previews and
borders belong in the widget-specific variables.

# Terminal

- **Ghostty:** `xterm-ghostty`; Shift+Enter sends a newline to CLI agents; padding
  keeps status bars clear of the rounded window corners.
- **tmux:** prefix is `` ` ``; `-` and `\` split; `Ctrl+h/j/k/l` moves across tmux panes
  and Neovim splits; `prefix Tab` opens extrakto; in copy mode `o` opens the
  selection and `Ctrl+o` opens it in Neovim. Requires 3.3+ for rounded popups and
  3.7+ to follow light/dark (older versions stay dark). Uses `tmux-256color`.
- **Remote hosts:** install the `xterm-ghostty` and `tmux-256color` terminfo entries
  instead of overriding `TERM`.
- **Yazi:** wider preview column (1:3:4), images up to 1600 px, wrapped text.
  Images work inside tmux through passthrough.

# Neovim

Leader is Space. Requires Neovim 0.12+, plus Go, Node.js, `uv`, `tree-sitter-cli`,
and a C compiler for Mason and treesitter. Restart Neovim after config changes.

**Formatting.** conform formats on save (3 s timeout; failures don't block the
write). `Space F` formats manually; `:ConformInfo` shows status.

| Filetype | Formatter |
| --- | --- |
| Go | `goimports` → `gofumpt` |
| Python | Ruff organize imports → Ruff format |
| sh / bash | `shfmt` |
| Lua | StyLua |
| YAML, JSON, Markdown | Prettier |
| TOML | Taplo |
| Others | LSP formatter, then trim whitespace |

Zsh gets whitespace trimming only; `shfmt` doesn't understand Zsh.

**Debugging.** [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) and
[nvim-dap-python](https://codeberg.org/mfussenegger/nvim-dap-python) supply the
adapters and launch configurations.

- `Space t d` debugs the nearest test (Go and Python, through neotest) from any
  starting directory. Python projects need a marker such as `pyproject.toml`.
- `F5` lists the stock configurations, which assume Neovim was started at the
  project root. For Go, pick **Debug Package**; **Debug** builds only the current
  file.
- Python code runs with the project's `.venv`/`venv`. The test runner (unittest or
  pytest) is picked from the project's config.

Mason Tool Installer keeps the formatters, `delve`, and `debugpy` installed
(`:MasonToolsInstallSync` waits for it). Avoid `:MasonToolsClean`: language servers
are managed separately by mason-lspconfig.

**AI agents.** omp and Cursor Agent run through Sidekick in tmux sessions that
outlive Neovim; toggling again reconnects.

| Keys | Action |
| --- | --- |
| `Space o o` / `Space o f` | Toggle / focus omp |
| `Space o s` (visual) | Send selection to omp's draft |
| `Space c c` / `Space c s` | Toggle Cursor Agent / send selection |
| `Space a c` / `Space a f` | Toggle / focus Claude Code (needs the `claude` CLI) |
| `Space a s` (visual) | Send selection to Claude Code |
| `Space a a` / `Space a d` | Accept / deny a Claude Code diff |

# Zed

Mirrors the Neovim setup: vim mode, Gruvbox Soft following macOS appearance, the
same font, format on save, and hidden chrome. Space-leader keys match Neovim
(`space f f/g/b`, `space h …` hunks, `space z` zen, `vv`/`ss` splits, `;` command
palette, `Ctrl+h/j/k/l` between panes, `F2` project panel). Agents (omp, Claude,
Cursor) connect over ACP; inline edit predictions are off. `debug.json` holds Go
and Python scenarios (`F4` to pick one). Project-specific ones go in
`<project>/.zed/debug.json`.

# omp

`omp/.config/omp/agent/config.yml` routes models by role across the Anthropic,
ChatGPT (Codex), and Grok subscriptions:

| Role | Model | Fallback |
| --- | --- | --- |
| `default` | Claude Opus 5.5, auto thinking | GPT-6 Astra |
| `slow`, `plan` | GPT-6 Astra, high | Claude Opus 5.5, high |
| `vision` | Claude Opus 5.5, high | GPT-6 Sol, high |
| `task` (subagents) | GPT-6 Sol, auto thinking | Grok 4.7 |
| `smol` (`scout` at medium) | Grok 4.7, low | GPT-6 Sol, low |
| `tiny`, `commit`, `sonic` | GPT-6 Luna, low | Grok 4.7, low |
| `advisor`, `reviewer`, `security-reviewer` | GPT-6 Astra, high | Claude Opus 5.5, high |
| `judge` | TypeSafe JEV | JEV preview, then `@tiny` |

Fallbacks switch provider, so one exhausted subscription doesn't stall a role.
Claude Fable is left out: on Claude Pro it is billed as metered extra usage.
JEV makes omp's small internal decisions: the effort level for `auto` roles,
whether a stop was premature (`features.unexpectedStopDetection: smart`), judged
rules, AI git staging, and the `find` tool, which is enabled only with JEV. Run
`/login typesafe` once per machine. Memory is local, with autolearn on. Restart
omp after config changes; toggling Sidekick only reconnects.

# Maintenance

- `topgrade` updates everything (review `topgrade.toml` first).
- `uv-tools-upgrade` upgrades `uv tool` installs; `make python-host` upgrades
  Neovim's pynvim.
- Lazy's restore returns Neovim plugins to `lazy-lock.json`.
- `make all` relinks after repository changes.
