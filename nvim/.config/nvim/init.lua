-- Performance optimizations
vim.loader.enable() -- Enable native Lua loader
vim.opt.shadafile = "NONE" -- Disable shada on init
vim.opt.updatetime = 250 -- Faster updates
vim.g.python3_host_prog = '~/.virtualenvs/neovim3/bin/python'

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
   "git",
   "clone",
   "--filter=blob:none",
   "https://github.com/folke/lazy.nvim.git",
   "--branch=stable",
   lazypath,
 })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = " "

-- Plugin specifications
require("lazy").setup({
 -- Theme (load immediately)
  {
   "f-person/auto-dark-mode.nvim",
   dependencies = {
     "ellisonleao/gruvbox.nvim",
   },
   lazy = false,
   priority = 1000,
   config = function()
     -- Setup gruvbox first
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

     -- Setup auto-dark-mode
     require('auto-dark-mode').setup({
       update_interval = 1000,
       set_dark_mode = function()
         vim.o.background = 'dark'
         vim.cmd('colorscheme gruvbox')
       end,
       set_light_mode = function()
         vim.o.background = 'light'
         vim.cmd('colorscheme gruvbox')
       end,
     })

     -- Manual toggle still available
     vim.keymap.set('n', '<leader>tb', function()
       vim.o.background = vim.o.background == "dark" and "light" or "dark"
     end, { desc = "Toggle background dark/light" })
   end,
 },

 -- Fuzzy finder
 {
   'nvim-telescope/telescope.nvim',
   cmd = "Telescope",
   keys = {
     { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
     { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
     { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
     { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
   },
   dependencies = { 'nvim-lua/plenary.nvim' },
 },

 -- LSP Configuration
 {
   "neovim/nvim-lspconfig",
   event = { "BufReadPre", "BufNewFile" },
   dependencies = {
     { "williamboman/mason.nvim", cmd = "Mason" },
     "williamboman/mason-lspconfig.nvim",
   },
   config = function()
     require("mason").setup()
     require("mason-lspconfig").setup({
       ensure_installed = { "gopls", "pyright", "bashls", "yamlls" },
     })

     -- LSP mappings
     local function setup_lsp_mappings(client, bufnr)
       local opts = { buffer = bufnr }
       vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
       vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
       vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
       vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
       vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
       vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
       vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
       vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
       vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
       vim.keymap.set('n', '<space>wl', function()
         print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
       end, opts)
       vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
       vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
       vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
       vim.keymap.set('n', '<space>f', function()
         vim.lsp.buf.format { async = true }
       end, opts)
     end

     -- Language specific LSP setup
     local lspconfig = require('lspconfig')

     -- Go
     vim.api.nvim_create_autocmd("FileType", {
       pattern = "go",
       callback = function()
         lspconfig.gopls.setup {
           on_attach = setup_lsp_mappings
         }
       end
     })

     -- Python
     vim.api.nvim_create_autocmd("FileType", {
       pattern = "python",
       callback = function()
         lspconfig.pyright.setup {
           on_attach = setup_lsp_mappings
         }
       end
     })

     -- Bash
     vim.api.nvim_create_autocmd("FileType", {
       pattern = "sh",
       callback = function()
         lspconfig.bashls.setup {
           on_attach = setup_lsp_mappings
         }
       end
     })

     -- YAML
     vim.api.nvim_create_autocmd("FileType", {
       pattern = "yaml",
       callback = function()
         lspconfig.yamlls.setup {
           on_attach = setup_lsp_mappings
         }
       end
     })
   end,
 },

 -- Autocompletion
 {
   "hrsh7th/nvim-cmp",
   event = { "InsertEnter", "CmdlineEnter" },
   dependencies = {
     {
       "L3MON4D3/LuaSnip",
       event = "InsertEnter",
       dependencies = {"saadparwaiz1/cmp_luasnip"}
     },
     "hrsh7th/cmp-nvim-lsp",
   },
   config = function()
     local cmp = require('cmp')
     cmp.setup({
       snippet = {
         expand = function(args)
           require('luasnip').lsp_expand(args.body)
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

 -- Treesitter
 {
   "nvim-treesitter/nvim-treesitter",
   event = { "BufReadPost", "BufNewFile" },
   cmd = { "TSUpdate", "TSInstall" },
   build = ":TSUpdate",
   config = function()
     require("nvim-treesitter.configs").setup({
       ensure_installed = { "go", "python", "bash", "yaml", "lua", "vim" },
       auto_install = true,
       highlight = { enable = true },
     })
   end,
 },

 -- File explorer
 {
   "nvim-neo-tree/neo-tree.nvim",
   cmd = "Neotree",
   keys = {
     { "<F2>", ":Neotree toggle<CR>", desc = "Toggle Neotree" },
   },
   dependencies = {
     "nvim-lua/plenary.nvim",
     "nvim-tree/nvim-web-devicons",
     "MunifTanjim/nui.nvim",
   },
 },

 -- Git integration
 {
   "tpope/vim-fugitive",
   cmd = { "Git", "Gwrite", "Gcommit", "Gpush", "Gpull" },
 },

 -- Status line
 {
   'nvim-lualine/lualine.nvim',
   event = "VeryLazy",
   dependencies = { 'nvim-tree/nvim-web-devicons' },
   config = function()
     require('lualine').setup()
   end,
 },

 -- Auto pairs
 {
   "windwp/nvim-autopairs",
   event = "InsertEnter",
   config = function() require("nvim-autopairs").setup {} end,
 },

 -- Comment toggler
 {
   'numToStr/Comment.nvim',
   event = "BufReadPost",
   config = function() require('Comment').setup() end,
 },

 -- Indent guides
 {
   "lukas-reineke/indent-blankline.nvim",
   event = "BufReadPost",
   main = "ibl",
   config = function() require("ibl").setup() end,
 },

 -- Which-key
 {
   "folke/which-key.nvim",
   event = "VeryLazy",
   config = function() require("which-key").setup() end,
 },

 -- Go support
 {
   "fatih/vim-go",
   ft = "go",
   config = function()
     vim.g.go_highlight_functions = 1
     vim.g.go_highlight_methods = 1
     vim.g.go_highlight_structs = 1
     vim.g.go_highlight_operators = 1
     vim.g.go_highlight_build_constraints = 1

     -- Additional performance optimizations for vim-go
     vim.g.go_code_completion_enabled = 0  -- Using LSP instead
     vim.g.go_gopls_enabled = 0           -- Using LSP instead
     vim.g.go_template_autocreate = 0     -- Disable template auto creation
     vim.g.go_auto_type_info = 0         -- Disable automatic type info
     vim.g.go_auto_sameids = 0           -- Disable automatic same ids
     vim.g.go_fmt_autosave = 1           -- Keep auto format on save
     vim.g.go_doc_popup_window = 1       -- Use popup window for docs
   end,
 },

 -- YAML support
 {
   "stephpy/vim-yaml",
   ft = "yaml",
 },

 -- Enhanced Python indentation
 {
   "Vimjas/vim-python-pep8-indent",
   ft = "python",
 },
})

-- General settings
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

-- Set backup, swap, and undo directories
local nvim_data = vim.fn.stdpath('data')
vim.opt.backupdir = nvim_data .. '/backup'
vim.opt.directory = nvim_data .. '/swap'
vim.opt.undodir = nvim_data .. '/undo'

-- Ensure directories exist
for _, dir in ipairs({ vim.opt.backupdir:get()[1], vim.opt.directory:get()[1], vim.opt.undodir:get()[1] }) do
   if vim.fn.isdirectory(dir) == 0 then
       vim.fn.mkdir(dir, "p")
   end
end

-- Key mappings
vim.keymap.set('n', '<leader>w', ':bdelete<CR>')
vim.keymap.set('n', 'gp', '`[v`]')
vim.keymap.set('n', 'S', ':nohlsearch<CR>')
vim.keymap.set('n', '<S-Tab>', ':bnext<CR>')
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', 'vv', ':vsplit<CR>')
vim.keymap.set('n', 'ss', ':split<CR>')
vim.keymap.set('n', ';', ':')
vim.keymap.set('v', ';', ':')

-- Auto-commands
vim.api.nvim_create_autocmd("BufWritePre", {
 pattern = "*",
 callback = function()
   local save_cursor = vim.fn.getpos(".")
   vim.cmd [[%s/\s\+$//e]]
   vim.fn.setpos(".", save_cursor)
 end,
})
