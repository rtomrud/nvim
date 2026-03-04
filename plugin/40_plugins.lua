-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
    'bash',
    'c',
    'css',
    'dockerfile',
    'html',
    'markdown_inline',
    'java',
    'javadoc',
    'javascript',
    'jsdoc',
    'json',
    'jsx',
    'php',
    'python',
    'sql',
    'tsx',
    'typescript',
    'yaml',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  -- vim.lsp.enable({
  --   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
  -- })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    -- formatters_by_ft = { lua = { 'stylua' } },
    formatters_by_ft = {
      css = { 'prettier' },
      graphql = { 'prettier' },
      html = { 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      java = { 'prettier_plugin_java' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      php = { 'prettier_plugin_php' },
      scss = { 'prettier' },
      sql = { 'prettier_plugin_sql_cst' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      vue = { 'prettier' },
      xml = { 'prettier_plugin_xml' },
      yaml = { 'prettier' },
    },

    formatters = {
      prettier = {
        command = "prettier",
      },
      prettier_plugin_java = {
        inherit = "prettier",
        append_args = { "--plugin=prettier-plugin-java" },
      },
      prettier_plugin_php = {
        inherit = "prettier",
        append_args = { "--plugin=@prettier/plugin-php" },
      },
      prettier_plugin_sql_cst = {
        inherit = "prettier",
        append_args = { "--plugin=prettier-plugin-sql-cst" },
        options = {
          ft_parsers = {
            sql = "postgresql",
          },
        },
      },
      prettier_plugin_xml = {
        inherit = "prettier",
        append_args = { "--plugin=@prettier/plugin-xml" },
      },
    }
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add({ 'https://github.com/rafamadriz/friendly-snippets' }) end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add({ 'https://github.com/mason-org/mason.nvim' })
--   require('mason').setup()
-- end)
now_if_args(function()
  add({
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
  })

  require('mason').setup()
  require('mason-lspconfig').setup({
    ensure_installed = {
      'eslint',
      'jdtls',
      'lua_ls',
      'phpactor',
      'ts_ls',
    },
    automatic_enable = true,
  })
end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- Config.now(function()
--  -- Install only those that you need
--  add({
--    'https://github.com/sainnhe/everforest',
--    'https://github.com/Shatur/neovim-ayu',
--    'https://github.com/ellisonleao/gruvbox.nvim',
--  })
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)
Config.now(function()
  add({ 'https://github.com/projekt0n/github-nvim-theme' })
  require('github-theme').setup({})
  vim.cmd('colorscheme github_dark_default')
end)

-- Detect indentation style
Config.now(function()
  add({ 'https://github.com/NMAC427/guess-indent.nvim' })
  require('guess-indent').setup({})
end)

-- Code completion
Config.now(function()
  add({
    'https://github.com/milanglacier/minuet-ai.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  })

  require('minuet').setup({
    lsp = {
      enabled_ft = {},
      disabled_ft = {},
      enabled_auto_trigger_ft = {},
      disabled_auto_trigger_ft = {},
      warn_on_blink_or_cmp = true,
      adjust_indentation = true,
    },
    virtualtext = {
      auto_trigger_ft = {},
      auto_trigger_ignore_ft = {},
      keymap = {
        accept = '<C-y>',
        accept_line = nil,
        accept_n_lines = nil,
        next = '<C-n>',
        prev = '<C-p>',
        dismiss = nil,
      },
      show_on_completion_menu = false,
    },
    provider = 'openai_fim_compatible',
    context_window = 4096,
    context_ratio = 0.75,
    throttle = 1000,
    debounce = 400,
    notify = 'verbose', -- 'debug', 'verbose', 'warn', 'error'
    request_timeout = 30,
    curl_cmd = 'curl',
    curl_extra_args = {},
    add_single_line_entry = false,
    n_completions = 2,
    after_cursor_filter_length = 15,
    before_cursor_filter_length = 2,
    proxy = nil,
    enable_predicates = {},
    provider_options = {
      openai_fim_compatible = {
        model = 'huggingface.co/unsloth/qwen3-coder-30b-a3b-instruct-gguf:Q4_K_M',
        stream = true,
        end_point = 'http://localhost:12434/v1/completions',
        api_key = 'TERM',
        name = 'DMR',
        optional = {
          stop = nil, -- { '\n\n' }
          max_tokens = nil,
        },
        transform = {},
        template = {
          prompt = function(prefix, suffix)
            return '<|fim_prefix|>' .. prefix .. '<|fim_suffix|>' .. suffix .. '<|fim_middle|>'
          end,
          suffix = false,
        },
      }
    },
  })
end)
