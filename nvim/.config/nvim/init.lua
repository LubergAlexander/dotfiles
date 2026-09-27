-- Performance optimizations
vim.loader.enable()
vim.opt.updatetime = 250
vim.g.python3_host_prog = vim.fn.expand('~/.virtualenvs/neovim3/bin/python')
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key
vim.g.mapleader = " "

-- Register filetypes that gopls/yamlls declare but Neovim doesn't know natively
vim.filetype.add({
    extension = { gotmpl = "gotmpl" },
    pattern = {
        [".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
        ["compose%.ya?ml"] = "yaml.docker-compose",
        ["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
        [".*/helm/.*%.ya?ml"] = "yaml.helm-values",
    },
})

-- Plugin specifications
require("lazy").setup({
    -- Theme: Gruvbox
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "",
                transparent_mode = false,
                italic = {
                    strings = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
            })
            vim.cmd("colorscheme gruvbox")
        end,
    },

    -- Icons (mini.icons to mock nvim-web-devicons)
    {
        "nvim-mini/mini.icons",
        lazy = true,
        opts = {},
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },

    -- Fuzzy finder (fzf-lua in place of Telescope)
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-mini/mini.icons" },
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<CR>",     desc = "Find Files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>FzfLua buffers<CR>",   desc = "Buffers" },
            { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help Tags" },
            { "<leader>fr", "<cmd>FzfLua oldfiles<CR>",  desc = "Recent Files" },
        },
        config = function()
            require("fzf-lua").setup({
                winopts = {
                    height = 0.60,
                    width = 0.80,
                    row = 0.50,
                    col = 0.50,
                    border = "rounded",
                    backdrop = false,
                },
                hls = {
                    normal = "Normal",
                    preview_normal = "Normal",
                    border = "GruvboxGray",
                    preview_border = "GruvboxGray",
                },
                fzf_opts = {
                    ["--layout"] = "reverse",
                    ["--info"] = "inline",
                },
                fzf_colors = {
                    true,
                    ["hl"] = { "fg", "GruvboxYellow" },
                    ["hl+"] = { "fg", "GruvboxYellow" },
                    ["prompt"] = { "fg", "GruvboxYellow" },
                    ["pointer"] = { "fg", "GruvboxYellow" },
                    ["marker"] = { "fg", "GruvboxYellow" },
                },
            })
        end,
    },

    -- Mason package manager
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {},
    },
    -- Mason-LSPConfig bridge
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = { "gopls", "basedpyright", "ruff", "bashls", "yamlls", "lua_ls" },
        },
    },

    -- Install formatter CLIs and debug adapters; language servers keep their bridge.
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "goimports", "gofumpt", "shfmt", "stylua", "prettier", "taplo",
                "delve", "debugpy", -- used by dap-go / dap-python via Mason's bin on PATH
            },
            integrations = {
                ["mason-lspconfig"] = false,
                ["mason-null-ls"] = false,
                ["mason-nvim-dap"] = false,
            },
        },
    },

    -- One synchronous save pipeline, independent of LSP attach/restart events.
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        cmd = "ConformInfo",
        dependencies = { "mason-org/mason.nvim" },
        keys = {
            {
                "<leader>F",
                function() require("conform").format({ async = true }) end,
                desc = "Format buffer",
            },
        },
        opts = {
            default_format_opts = { lsp_format = "fallback" },
            format_on_save = { timeout_ms = 3000 },
            formatters_by_ft = {
                go = { "goimports", "gofumpt" },
                python = { "ruff_organize_imports", "ruff_format" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                lua = { "stylua" },
                yaml = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                markdown = { "prettier" },
                toml = { "taplo" },
                -- Includes Go module/workspace files via gopls; Zsh is not Bash.
                ["_"] = { "trim_whitespace", lsp_format = "first" },
            },
        },
    },

    -- LSP configurations (Neovim 0.11+ native API)
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            -- blink.cmp registers its completion capabilities for '*' when it
            -- loads (BufReadPre), before any server starts on FileType.

            -- Configure LSP servers using vim.lsp.config (new in 0.11)
            vim.lsp.config('gopls', {
                settings = {
                    gopls = {
                        analyses = { unusedparams = true, shadow = true },
                        staticcheck = true,
                        gofumpt = true,
                    },
                },
            })
            vim.lsp.config('ruff', {
                init_options = { settings = { logLevel = "info" } }
            })
            -- Same server and strictness as Zed (basedpyright in "standard" mode);
            -- Ruff owns import organization.
            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        disableOrganizeImports = true,
                        analysis = { typeCheckingMode = "standard" },
                    },
                },
            })
            vim.lsp.config('bashls', {}) -- Bash
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = "" },
                    },
                },
            })
            -- lazydev.nvim supplies Neovim runtime/plugin types on demand.
            vim.lsp.config('lua_ls', {
                settings = { Lua = { workspace = { checkThirdParty = false } } },
            })

            -- Global LSP on-attach keybindings (modern pattern)
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
                callback = function(event)
                    local bufnr = event.buf
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then return end

                    -- Disable Ruff hover (to let Pyright handle hover info)
                    if client.name == 'ruff' then
                        client.server_capabilities.hoverProvider = false
                    end

                    local opts = { buffer = bufnr, silent = true }

                    -- Only non-default keymaps; Neovim 0.11+ already ships:
                    -- grn (rename), gra (code action), grr (references),
                    -- gri (implementation), grt (type definition), gO (symbols),
                    -- K (hover), <C-s> (signature help), [d/]d (diagnostics)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
                end
            })
        end,
    },

    -- Lua LSP types for the Neovim API and installed plugins, loaded lazily
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
        },
    },

    -- Auto-completion (blink.cmp — LSP/path/buffer/snippets built in)
    {
        "saghen/blink.cmp",
        version = "1.*", -- v2 still has breaking changes; stay on stable
        -- Must load before the first LSP server starts so its capabilities apply.
        event = { "BufReadPre", "BufNewFile", "InsertEnter", "CmdlineEnter" },
        opts = {
            -- 'enter' preset: <CR> accepts, <C-space> opens menu/docs,
            -- <C-e> hides, <C-b>/<C-f> scroll docs (matches old cmp mappings)
            keymap = { preset = "enter" },
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
    },

    -- Treesitter for syntax highlighting and indent (main branch — requires Neovim 0.12+)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()

            local parsers = {
                "go", "python", "bash", "yaml", "lua", "vim", "vimdoc",
                "gomod", "gosum", "markdown", "markdown_inline",
                "json", "toml", "dockerfile", "helm", "gotmpl", "hcl",
                "make", "diff", "gitcommit",
            }
            require("nvim-treesitter").install(parsers)

            local indent_disabled = { python = true, yaml = true }

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local buf = args.buf
                    local ft = args.match
                    local lang = vim.treesitter.language.get_lang(ft) or ft
                    local ok = pcall(vim.treesitter.start, buf, lang)
                    if ok and not indent_disabled[lang] then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },

    -- File explorer (Neo-tree)
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        keys = {
            { "<F2>", ":Neotree toggle<CR>", desc = "Toggle Neotree" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-mini/mini.icons",
            "MunifTanjim/nui.nvim",
        },
    },

    -- Git integration (Fugitive)
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "Gwrite" },
    },

    -- Git hunk signs, staging, and blame
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Git: " .. desc })
                end
                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hd", gs.diffthis, "Diff against index")
            end,
        },
    },

    -- Status line (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-mini/mini.icons" },
        config = function()
            require("lualine").setup({
                options = {
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    theme = function()
                        local palette = require("gruvbox").palette
                        local light = vim.o.background == "light"
                        local canvas_bg = light and palette.light0 or palette.dark0
                        local bar_bg = light and palette.light1 or palette.dark1
                        local fg = light and palette.dark1 or palette.light1
                        local muted = light and palette.dark4 or palette.gray
                        local accent = light and palette.faded_yellow or palette.bright_yellow
                        local segment_bg = light and palette.light2 or palette.dark2
                        local theme = {
                            normal = {
                                a = { fg = canvas_bg, bg = accent, gui = "bold" },
                                b = { fg = fg, bg = segment_bg },
                                c = { fg = fg, bg = bar_bg },
                            },
                            inactive = {
                                a = { fg = muted, bg = segment_bg },
                                b = { fg = muted, bg = segment_bg },
                                c = { fg = muted, bg = bar_bg },
                            },
                        }
                        for mode, color in pairs({
                            insert = light and palette.faded_blue or palette.bright_blue,
                            visual = light and palette.faded_orange or palette.bright_orange,
                            replace = light and palette.faded_red or palette.bright_red,
                            command = light and palette.faded_green or palette.bright_green,
                            terminal = light and palette.faded_aqua or palette.bright_aqua,
                        }) do
                            theme[mode] = { a = { fg = canvas_bg, bg = color, gui = "bold" } }
                        end
                        return theme
                    end,
                },
                sections = { lualine_x = { "filetype" } },
            })
        end,
    },

    -- Auto pairs for brackets/quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup() end,
    },

    -- Comment toggling: native since Neovim 0.10 (gcc toggles a line,
    -- gc{motion}/gc in visual mode comments a range) — no plugin needed.

    -- Indent guides (blankline)
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPost",
        main = "ibl",
        config = function()
            require("ibl").setup()
        end,
    },

    -- Which-key (keybinding hints)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                plugins = { spelling = true }, -- example: enable spelling suggestions
            })
        end,
    },

    -- Python indentation (PEP8-compliant indenting)
    {
        "Vimjas/vim-python-pep8-indent",
        ft = "python",
    },

    -- Ctrl-h/j/k/l across nvim splits and tmux panes (pairs with the tmux plugin)
    {
        "christoomey/vim-tmux-navigator",
        cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
        keys = {
            { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Navigate left" },
            { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Navigate down" },
            { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Navigate up" },
            { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Navigate right" },
            { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
        },
    },

    -- Zen mode (Zed: space z): opaque canvas, bare 100-col text column, no gutter,
    -- diagnostics, hints, indent guides, statusline, or tmux bar. Restored on exit.
    {
        "folke/snacks.nvim",
        keys = {
            { "<leader>z", function() require("snacks").zen() end, desc = "Toggle zen mode" },
        },
        opts = {
            zen = {
                toggles = { dim = false, git_signs = false, diagnostics = false, inlay_hints = false },
                show = { statusline = false, tabline = false },
                win = {
                    width = 100,
                    -- Opaque Normal-colored backdrop hides the original window behind the float.
                    backdrop = { transparent = false, blend = 99 },
                    wo = {
                        number = false,
                        relativenumber = false,
                        signcolumn = "no",
                        foldcolumn = "0",
                        statuscolumn = "",
                        cursorline = false,
                        colorcolumn = "",
                        list = false,
                    },
                },
                on_open = function()
                    vim.g.zen_ruler, vim.o.ruler = vim.o.ruler, false
                    if vim.fn.exists(":IBLDisable") == 2 then vim.cmd("IBLDisable") end
                    if vim.env.TMUX then vim.system({ "tmux", "set", "status", "off" }) end
                end,
                on_close = function()
                    vim.o.ruler = vim.g.zen_ruler ~= false
                    if vim.fn.exists(":IBLEnable") == 2 then vim.cmd("IBLEnable") end
                    if vim.env.TMUX then vim.system({ "tmux", "set", "-u", "status" }) end
                end,
            },
        },
    },

    -- Claude Code integration (same IDE protocol as the official VS Code
    -- extension: selection context, diff review in nvim; uses the claude CLI)
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
        keys = {
            { "<leader>ac", "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude Code" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",      desc = "Focus Claude Code" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>",       mode = "v",                 desc = "Send selection to Claude" },
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny Claude diff" },
        },
    },

    -- AI CLIs in persistent tmux-backed terminals
    {
        "folke/sidekick.nvim",
        opts = {
            nes = { enabled = false }, -- no Copilot LSP; CLI integration only
            cli = {
                mux = { backend = "tmux", enabled = true },
                tools = {
                    omp = {
                        cmd = { "omp" },
                        is_proc = "\\<omp\\>",
                        keys = {
                            prompt = false, -- let OMP cycle models with Ctrl+P
                            stopinsert = false, -- let OMP queue follow-ups with Ctrl+Q
                        },
                    },
                },
            },
        },
        keys = {
            {
                "<leader>cc",
                function() require("sidekick.cli").toggle({ name = "cursor", focus = true }) end,
                desc = "Toggle Cursor Agent",
            },
            {
                "<leader>cs",
                function() require("sidekick.cli").send({ name = "cursor", msg = "{selection}" }) end,
                mode = "v",
                desc = "Send selection to Cursor Agent",
            },
            {
                "<leader>oo",
                function() require("sidekick.cli").toggle({ name = "omp", focus = true }) end,
                desc = "Toggle OMP",
            },
            {
                "<leader>of",
                function() require("sidekick.cli").focus({ name = "omp" }) end,
                desc = "Focus OMP",
            },
            {
                "<leader>os",
                function() require("sidekick.cli").send({ name = "omp", msg = "{selection}", focus = true }) end,
                mode = "v",
                desc = "Send selection to OMP",
            },
        },
    },
    -- Debugging: nvim-dap + UI + virtual text; language setup from the standard
    -- extensions (dap-go, dap-python). Mason Tool Installer provides dlv and debugpy.
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<F5>",       desc = "DAP: Continue/Start" },
            { "<F10>",      desc = "DAP: Step Over" },
            { "<F11>",      desc = "DAP: Step Into" },
            { "<F12>",      desc = "DAP: Step Out" },
            { "<leader>db", desc = "DAP: Toggle Breakpoint" },
            { "<leader>dB", desc = "DAP: Conditional Breakpoint" },
            { "<leader>dl", desc = "DAP: Logpoint" },
            { "<leader>dr", desc = "DAP: REPL" },
            { "<leader>du", desc = "DAP: Toggle UI" },
            { "<leader>dx", desc = "DAP: Terminate" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- UI + virtual text
            require("dapui").setup({
                controls = { enabled = true, element = "repl" },
                floating = { border = "rounded" },
                layouts = {
                    { elements = { { id = "scopes", size = 0.45 }, "breakpoints", "stacks", "watches" }, size = 0.33, position = "left" },
                    { elements = { "repl", "console" },                                                  size = 0.25, position = "bottom" },
                },
            })
            require("nvim-dap-virtual-text").setup({ commented = true })

            -- Auto-open/close UI
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

            -- Adapters and stock configurations. dap-go: Debug Package, Debug test, attach, …
            -- dap-python: launch file, venv detection (cwd or LSP root), test_method().
            require("dap-go").setup()
            require("dap-python").setup("debugpy-adapter")

            -- Keymaps (matching common DAP UX)
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { silent = true, desc = "DAP: " .. desc })
            end
            map("n", "<F5>", dap.continue, "Continue/Start")
            map("n", "<F10>", dap.step_over, "Step Over")
            map("n", "<F11>", dap.step_into, "Step Into")
            map("n", "<F12>", dap.step_out, "Step Out")
            map("n", "<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
            map("n", "<leader>dB", function()
                vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
                    if cond then dap.set_breakpoint(cond) end
                end)
            end, "Conditional Breakpoint")
            map("n", "<leader>dl", function()
                vim.ui.input({ prompt = "Log point: " }, function(msg)
                    if msg then dap.set_breakpoint(nil, nil, msg) end
                end)
            end, "Logpoint")
            map("n", "<leader>dr", dap.repl.open, "REPL")
            map("n", "<leader>du", dapui.toggle, "Toggle UI")
            map("n", "<leader>dx", dap.terminate, "Terminate")

            -- Optional: annotate which-key if you like
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>d",  group = "Debug" },
                    { "<leader>db", desc = "Toggle Breakpoint" },
                    { "<leader>dB", desc = "Conditional Breakpoint" },
                    { "<leader>dl", desc = "Logpoint" },
                    { "<leader>dr", desc = "REPL" },
                    { "<leader>du", desc = "Toggle UI" },
                    { "<leader>dx", desc = "Terminate" },
                })
            end
        end,
    },

    -- Test runner: neotest with Go and Python adapters; debugging goes through dap-go/dap-python.
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
            "nvim-neotest/neotest-python",
        },
        keys = {
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Test: Run current file" },
            { "<leader>tn", function() require("neotest").run.run() end,                     desc = "Test: Run nearest test" },
            { "<leader>ts", function() require("neotest").summary.toggle() end,              desc = "Test: Toggle summary" },
            { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Show output" },
            { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug nearest" },
            { "<leader>tA", function() require("neotest").run.run(vim.fn.getcwd()) end,      desc = "Test: Run all tests (recursive)" },
            { "<leader>tp", function() require("neotest").output_panel.toggle() end,         desc = "Test: Toggle output panel" },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-golang")({
                        go_test_args = { "-count=1", "-timeout=60s", "-race" },
                    }),
                    require("neotest-python"),
                },
                output = {
                    enabled = true,
                    open_on_run = "short",
                },
                quickfix = {
                    enabled = false,
                },
                status = {
                    enabled = true,
                    virtual_text = true,
                    signs = true,
                },
                icons = {
                    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                },
                summary = {
                    animated = true,
                    enabled = true,
                },
                discovery = {
                    enabled = true,
                },
            })
        end,
    },
}, {
    rocks = { enabled = false }, -- no plugin needs luarocks
})

-- General editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.backup = true
vim.opt.undofile = true

-- Set backup, swap, and undo file directories
local nvim_data = vim.fn.stdpath('data')
vim.opt.backupdir = nvim_data .. '/backup//'
vim.opt.directory = nvim_data .. '/swap//'
vim.opt.undodir = nvim_data .. '/undo//'

-- Ensure those directories exist
for _, dir in ipairs({ vim.opt.backupdir:get()[1], vim.opt.directory:get()[1], vim.opt.undodir:get()[1] }) do
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
end

-- Custom key mappings
vim.keymap.set('n', '<leader>w', ':bdelete<CR>')      -- Close buffer (no overlap with workspace keys now)
vim.keymap.set('n', 'gp', '`[v`]', { remap = false }) -- Reselect last pasted text
vim.keymap.set('n', 'S', ':nohlsearch<CR>')           -- Clear search highlight
vim.keymap.set('n', '<S-Tab>', ':bnext<CR>')          -- Next buffer
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")          -- Move highlighted block down
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")          -- Move highlighted block up
vim.keymap.set('n', 'vv', ':vsplit<CR>')
vim.keymap.set('n', 'ss', ':split<CR>')
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- 'background' follows the terminal (OSC 11 + DEC 2031 theme updates); setting
-- it at runtime reloads gruvbox. Never set it during startup: that disables tracking.
vim.keymap.set('n', '<leader>tb', function()
    vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end, { desc = "Toggle background dark/light" })
