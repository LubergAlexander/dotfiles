-- Performance optimizations
vim.loader.enable()
vim.opt.shadafile = "NONE"
vim.opt.updatetime = 250
vim.g.python3_host_prog = '~/.virtualenvs/neovim3/bin/python'
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key
vim.g.mapleader = " "

-- Plugin specifications
require("lazy").setup({
    -- Theme: Gruvbox
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "light",
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
        "echasnovski/mini.icons",
        lazy = true,
        opts = {},
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },

    -- Automatic dark/light mode switching
    {
        "cormacrelf/dark-notify",
        lazy = false,
        priority = 999,
        config = function()
            local dn = require('dark_notify')
            dn.run({
                schemes = {
                    dark = { colorscheme = "gruvbox", background = "dark" },
                    light = { colorscheme = "gruvbox", background = "light" },
                },
                onchange = function()
                    vim.cmd('colorscheme gruvbox')
                end,
            })
            vim.keymap.set('n', '<leader>tb', function()
                dn.toggle()
            end, { desc = "Toggle background dark/light" })
        end,
    },

    -- Fuzzy finder (fzf-lua in place of Telescope)
    {
        "ibhagwan/fzf-lua",
        dependencies = { "echasnovski/mini.icons" },
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<CR>",     desc = "Find Files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>FzfLua buffers<CR>",   desc = "Buffers" },
            { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help Tags" },
            { "<leader>fr", "<cmd>FzfLua oldfiles<CR>",  desc = "Recent Files" },
        },
        config = function()
            require("fzf-lua").setup({}) -- using default telescope-like behavior
        end,
    },

    -- Mason package manager
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = {},
    },
    -- Mason-LSPConfig bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "gopls", "pyright", "ruff", "bashls", "yamlls", "lua_ls" },
            automatic_installation = true,
        },
    },

    -- LSP configurations (Neovim 0.11+ native API)
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
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
            vim.lsp.config('pyright', {
                settings = {
                    pyright = { disableOrganizeImports = true },
                    python = {
                        analysis = {
                            ignore = { "*" }, -- Pyright linting off (use Ruff)
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
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
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim' } },
                        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
                    }
                }
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

                    -- LSP-related keymaps:
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                    -- Workspace management (optional, can remove if not used):
                    -- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                    -- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    -- vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
                    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                    -- Code actions and rename:
                    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    -- References (adjusted mapping to avoid overlap):
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    -- If you prefer grouping under 'gr', use:
                    -- vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)
                    -- vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
                    -- vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, opts)
                    -- vim.keymap.set('n', 'grt', vim.lsp.buf.type_definition, opts)
                    -- vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, opts)

                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
                    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format({ async = true }) end, opts) -- moved to <leader>F

                    -- Format on save if supported by this server
                    if client:supports_method('textDocument/formatting') then -- use colon method
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ async = false })
                            end
                        })
                    end
                end
            })

            -- Go: organize imports on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    vim.lsp.buf.code_action({
                        context = { only = { "source.organizeImports" } },
                        apply = true
                    })
                end
            })
        end,
    },

    -- Auto-completion (nvim-cmp and LuaSnip)
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            -- Snippet engine and sources
            {
                "L3MON4D3/LuaSnip",
                version = "<CurrentMajor>.*",    -- follow latest release
                build = "make install_jsregexp", -- install extended regex support for snippets:contentReference[oaicite:2]{index=2}
                event = "InsertEnter",
                dependencies = { "saadparwaiz1/cmp_luasnip" }
            },
            "hrsh7th/cmp-nvim-lsp",
            -- (you can add other sources like cmp-buffer, cmp-path here if needed)
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- use LuaSnip to expand snippet
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })
        end,
    },

    -- Treesitter for syntax highlighting and indent
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "go", "python", "bash", "yaml", "lua", "vim", "gomod", "gosum", "markdown", "markdown_inline" },
                auto_install = true,
                highlight = { enable = true },
                indent = {
                    enable = true,
                    disable = { "python", "yaml" } -- disable TS indent for these (using vim-python-pep8-indent)
                },
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
            "echasnovski/mini.icons",
            "MunifTanjim/nui.nvim",
        },
    },

    -- Git integration (Fugitive)
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "Gwrite", "Gcommit", "Gpush", "Gpull" },
    },

    -- Status line (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "echasnovski/mini.icons" },
        config = function()
            require("lualine").setup()
        end,
    },

    -- Auto pairs for brackets/quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup() end,
    },

    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        event = "BufReadPost",
        config = function()
            require('Comment').setup({
                toggler  = { line = "gC", block = "gB" }, -- use gC to toggle line comment, gB for block
                opleader = { line = "gy", block = "gY" }, -- use gy motion to comment
                mappings = {
                    basic = true,                         -- set to false if you want to disable default `gc` mappings
                    extra = false,
                },
            })
        end,
    },

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

    -- Avante AI assistant plugin (with providers)
    {
        "yetone/avante.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.icons",
            "MeanderingProgrammer/render-markdown.nvim",
            "stevearc/dressing.nvim",
        },
        build = "make",
        event = "VeryLazy",
        opts = {
            provider = "claude",
            mode = "agentic",
            disabled_tools = { "bash", "python" },
            suggestion = { debounce = 100 },
            providers = {
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-sonnet-4-20250514",
                    timeout = 30000,
                    extra_request_body = { temperature = 0.0, max_tokens = 4096 },
                },
                openai = {
                    endpoint = os.getenv("OPENAI_API_URL") or "https://api.openai.com/v1",
                    model = "gpt-4o",
                    timeout = 30000,
                    extra_request_body = { temperature = 0.0, max_tokens = 4096 },
                },
                openrouter = {
                    endpoint = "https://openrouter.ai/api/v1",
                    model = "openai/gpt-4o",
                    timeout = 30000,
                    extra_request_body = { temperature = 0.0, max_tokens = 4096 },
                },
                grok = {
                    endpoint = "https://api.x.ai/v1",
                    model = "grok-2-1212",
                    timeout = 30000,
                    extra_request_body = { temperature = 0.0, max_tokens = 4096 },
                },
            },
            behaviour = {
                auto_approve_tool_permissions = false,
            },
        },
        config = function(_, opts)
            -- Disable unused renderers (no LaTeX, no HTML to avoid warnings)
            require('render-markdown').setup({
                html  = { enabled = false },
                latex = { enabled = false },
            })
            require("avante").setup(opts)
            vim.keymap.set("n", "<leader>am", function()
                local providers = { "claude", "openai", "openrouter", "grok" }
                vim.ui.select(providers, { prompt = "Switch Avante provider:" }, function(choice)
                    if choice then
                        require("avante").setup(vim.tbl_extend("force", opts, { provider = choice }))
                        vim.notify("Avante provider → " .. choice)
                    end
                end)
            end, { desc = "Switch Avante provider" })
        end,
    },
    -- Debugging: nvim-dap + UI + virtual text + Mason integration
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "jay-babu/mason-nvim-dap.nvim",
            "nvim-neotest/nvim-nio",
        },
        event = "VeryLazy",
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

            -- Adapters via Mason (debugpy, delve)
            require("mason-nvim-dap").setup({
                automatic_installation = true,
                ensure_installed = { "python", "delve" },
                handlers = {
                    -- Python (debugpy)
                    python = function()
                        dap.adapters.python = function(cb, _)
                            -- Use Mason's debugpy
                            local mason = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
                            cb({ type = "executable", command = mason, args = { "-m", "debugpy.adapter" } })
                        end
                        -- Prefer project venv for running the code (not the adapter)
                        local function project_python()
                            for _, p in ipairs({ ".venv/bin/python", "venv/bin/python", "env/bin/python" }) do
                                local f = vim.fn.getcwd() .. "/" .. p
                                if vim.fn.executable(f) == 1 then return f end
                            end
                            -- fallback to host python from your config
                            return vim.g.python3_host_prog or "python3"
                        end
                        dap.configurations.python = {
                            {
                                type = "python",
                                request = "launch",
                                name = "▶ Python: current file",
                                program = "${file}",
                                pythonPath = project_python,
                                console = "integratedTerminal",
                            },
                            {
                                type = "python",
                                request = "launch",
                                name = "▶ Python: module",
                                module = "pytest",
                                args = { "-q" },
                                justMyCode = false,
                                pythonPath = project_python,
                                console = "integratedTerminal",
                            },
                        }
                    end,

                    -- Go (dlv)
                    delve = function()
                        dap.adapters.delve = {
                            type = "server",
                            port = "${port}",
                            executable = {
                                command = "dlv",
                                args = { "dap", "-l", "127.0.0.1:${port}" },
                            },
                        }
                        dap.configurations.go = {
                            {
                                type = "delve",
                                name = "▶ Go: current file",
                                request = "launch",
                                program = "${file}",
                            },
                            {
                                type = "delve",
                                name = "▶ Go: package",
                                request = "launch",
                                program = "${workspaceFolder}",
                            },
                            {
                                type = "delve",
                                name = "▶ Go: test (pkg)",
                                request = "launch",
                                mode = "test",
                                program = "${workspaceFolder}",
                            },
                            {
                                type = "delve",
                                name = "▶ Go: test (file)",
                                request = "launch",
                                mode = "test",
                                program = "${file}",
                            },
                        }
                    end,
                },
            })

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
})

-- General editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.hidden = true
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

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

-- Trim trailing whitespace on save (for all files)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[ %s/\s\+$//e ]])
        vim.fn.setpos(".", save_cursor)
    end,
})
