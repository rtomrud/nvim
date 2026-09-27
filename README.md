# nvim config

## Set up config

Download [MiniMax](https://github.com/nvim-mini/MiniMax):

```bash
git clone --filter=blob:none https://github.com/nvim-mini/MiniMax ./MiniMax
```

Or pull updates if already installed:

```bash
git -C ./MiniMax pull
```

Set up config files:

```bash
nvim -l ./MiniMax/setup.lua
```

## Install dependencies

Install [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) via your package manager.

## Configure options

Configure options in [`10_options.lua`](./plugin/10_options.lua).

Use system clipboard:

```lua
vim.o.clipboard = 'unnamedplus'
```

Write swap file to disk 1 second after typing:

```lua
vim.o.updatetime = 1000
```

## Configure plugins

Configure plugins in [`40_plugins.lua`](./plugin/40_plugins.lua).

### Syntax highlight

Configure language parsers for `nvim-treesitter/nvim-treesitter`:

```lua
  local languages = {
    'bash',
    'c',
    'css',
    'dockerfile',
    'html',
    'java',
    'javadoc',
    'javascript',
    'jsdoc',
    'json',
    'jsx',
    'lua',
    'markdown',
    'markdown_inline',
    'php',
    'python',
    'sql',
    'tsx',
    'typescript',
    'vimdoc',
    'yaml',
  }
```

### Formatting

Configure formatters for `stevearc/conform.nvim`:

```lua
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
      -- Run only the first available formatter
      stop_after_first = true,
    },
    formatters_by_ft = {
      css = { 'oxfmt', 'prettier' },
      graphql = { 'oxfmt', 'prettier' },
      html = { 'oxfmt', 'prettier' },
      javascript = { 'deno_fmt', 'oxfmt', 'prettier' },
      javascriptreact = { 'deno_fmt', 'oxfmt', 'prettier' },
      json = { 'deno_fmt', 'oxfmt', 'prettier' },
      jsonc = { 'oxfmt', 'prettier' },
      less = { 'oxfmt', 'prettier' },
      markdown = { 'deno_fmt', 'oxfmt', 'prettier' },
      -- php = { 'prettier_plugin_php' }, -- Requires prettier_plugin_php below
      scss = { 'oxfmt', 'prettier' },
      sql = { 'postgres_lsp' },
      svelte = { 'oxfmt', 'prettier' },
      typescript = { 'deno_fmt', 'oxfmt', 'prettier' },
      typescriptreact = { 'deno_fmt', 'oxfmt', 'prettier' },
      vue = { 'oxfmt', 'prettier' },
      -- xml = { 'prettier_plugin_xml' }, -- Requires prettier_plugin_xml below
      yaml = { 'oxfmt', 'prettier' },
    },

    formatters = {
      postgres_lsp = {
        command = "postgres-language-server",
        args = { "format", "--write", "$FILENAME" },
        stdin = false,
      },
      -- Prettier plugins (must be installed with npm):
      -- prettier_plugin_php = {
      --   command = "prettier",
      --   args = "--stdin-filepath $FILENAME --plugin $(npm config get prefix)/lib/node_modules/@prettier/plugin-php/src/index.mjs",
      --   stdin = true,
      -- },
      -- prettier_plugin_xml = {
      --   command = "prettier",
      --   args = "--stdin-filepath $FILENAME --plugin $(npm config get prefix)/lib/node_modules/@prettier/plugin-xml/src/plugin.js",
      --   stdin = true,
      -- },
    }
  })
```

### LSPs

Add a package manager (`mason-org/mason.nvim`) for language servers, formatters and linters:

```lua
  add({ 'https://github.com/mason-org/mason.nvim' })

  require('mason').setup()
```

Install and enable language servers automatically with `mason-org/mason-lspconfig.nvim`:

```lua
  add({ 'https://github.com/mason-org/mason-lspconfig.nvim' })

  require('mason-lspconfig').setup({
    ensure_installed = {
      'denols',
      'eslint',
      'html',
      'jdtls',
      'lua_ls',
      'postgres_lsp',
      'ts_ls',
    },
  })
```

### Theming

Add a custom theme (`rose-pine/neovim`):

```lua
  add({ 'https://github.com/rose-pine/neovim' })

  require('rose-pine').setup({})

  vim.cmd('colorscheme rose-pine')
```

## Configure optional plugins

### Indentation

Detect indentation style automatically with `NMAC427/guess-indent.nvim`:

```lua
  add({ 'https://github.com/NMAC427/guess-indent.nvim' })

  require('guess-indent').setup({})
```

### Code completion

Enable code completion with `milanglacier/minuet-ai.nvim`:

```lua
  add({
    'https://github.com/milanglacier/minuet-ai.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  })

  require('minuet').setup({
    -- Enable or disable auto-completion. Note that you still need to add
    -- Minuet to your cmp/blink sources. This option controls whether cmp/blink
    -- will attempt to invoke minuet when minuet is included in cmp/blink
    -- sources. This setting has no effect on manual completion; Minuet will
    -- always be enabled when invoked manually. You can use the command
    -- `Minuet cmp/blink toggle` to toggle this option.
    cmp = {
      enable_auto_complete = false,
    },
    blink = {
      enable_auto_complete = false,
    },
    -- LSP is recommended only for built-in completion. If you are using
    -- `cmp` or `blink`, utilizing LSP for code completion from Minuet is *not*
    -- recommended.
    lsp = {
      enabled_ft = {},
      -- Filetypes excluded from LSP activation. Useful when `enabled_ft` = { '*' }
      disabled_ft = {},
      -- Enables automatic completion triggering using `vim.lsp.completion.enable`
      enabled_auto_trigger_ft = {},
      -- Filetypes excluded from autotriggering. Useful when `enabled_auto_trigger_ft` = { '*' }
      disabled_auto_trigger_ft = {},
      -- if true, warn the user that they should use the native source
      -- instead when the user is using blink or nvim-cmp.
      warn_on_blink_or_cmp = true,
      -- See README section [Built-in Completion, Mini.Completion, and LSP
      -- Setup] for more details on this option.
      adjust_indentation = true,
    },
    virtualtext = {
      -- Specify the filetypes to enable automatic virtual text completion,
      -- e.g., { 'python', 'lua' }. Note that you can still invoke manual
      -- completion even if the filetype is not on your auto_trigger_ft list.
      auto_trigger_ft = {},
      -- specify file types where automatic virtual text completion should be
      -- disabled. This option is useful when auto-completion is enabled for
      -- all file types i.e., when auto_trigger_ft = { '*' }
      auto_trigger_ignore_ft = {},
      keymap = {
        accept = '<C-y>',
        accept_line = nil,
        accept_n_lines = nil,
        -- Cycle to next completion item, or manually invoke completion
        next = '<C-n>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<C-p>',
        dismiss = nil,
      },
      -- Whether show virtual text suggestion when the completion menu
      -- (nvim-cmp or blink-cmp) is visible.
      show_on_completion_menu = false,
    },
    provider = 'openai_fim_compatible',
    -- the maximum total characters of the context before and after the cursor
    -- 16000 characters typically equate to approximately 4,000 tokens for
    -- LLMs.
    context_window = 16000,
    -- when the total characters exceed the context window, the ratio of
    -- context before cursor and after cursor, the larger the ratio the more
    -- context before cursor will be used. This option should be between 0 and
    -- 1, context_ratio = 0.75 means the ratio will be 3:1.
    context_ratio = 0.75,
    throttle = 1000, -- only send the request every x milliseconds, use 0 to disable throttle.
    -- debounce the request in x milliseconds, set to 0 to disable debounce
    debounce = 400,
    -- Control notification display for request status
    -- Notification options:
    -- false: Disable all notifications (use boolean false, not string "false")
    -- "debug": Display all notifications (comprehensive debugging)
    -- "verbose": Display most notifications
    -- "warn": Display warnings and errors only
    -- "error": Display errors only
    notify = 'verbose',
    -- The request timeout, measured in seconds. When streaming is enabled
    -- (stream = true), setting a shorter request_timeout allows for faster
    -- retrieval of completion items, albeit potentially incomplete.
    -- Conversely, with streaming disabled (stream = false), a timeout
    -- occurring before the LLM returns results will yield no completion items.
    request_timeout = 60,
    -- Command used to make HTTP requests.
    curl_cmd = 'curl',
    -- Extra arguments passed to curl (list of strings).
    curl_extra_args = {},
    -- If completion item has multiple lines, create another completion item
    -- only containing its first line. This option only has impact for cmp and
    -- blink. For virtualtext, no single line entry will be added.
    add_single_line_entry = true,
    -- The number of completion items encoded as part of the prompt for the
    -- chat LLM. For FIM model, this is the number of requests to send. It's
    -- important to note that when 'add_single_line_entry' is set to true, the
    -- actual number of returned items may exceed this value. Additionally, the
    -- LLM cannot guarantee the exact number of completion items specified, as
    -- this parameter serves only as a prompt guideline.
    n_completions = 3,
    --  Length of context after cursor used to filter completion text.
    --
    -- This setting helps prevent the language model from generating redundant
    -- text.  When filtering completions, the system compares the suffix of a
    -- completion candidate with the text immediately following the cursor.
    --
    -- If the length of the longest common substring between the end of the
    -- candidate and the beginning of the post-cursor context exceeds this
    -- value, that common portion is trimmed from the candidate.
    --
    -- For example, if the value is 15, and a completion candidate ends with a
    -- 20-character string that exactly matches the 20 characters following the
    -- cursor, the candidate will be truncated by those 20 characters before
    -- being delivered.
    after_cursor_filter_length = 15,
    -- Similar to after_cursor_filter_length but trim the completion item from
    -- prefix instead of suffix.
    before_cursor_filter_length = 2,
    -- proxy port to use
    proxy = nil,
    -- **List** of functions to execute. If any function returns `false`, Minuet
    -- will not trigger auto-completion. Manual completion can still be invoked,
    -- even if these functions evaluate to `false`, when using `nvim-cmp`,
    -- `blink-cmp`, or virtual text (excluding LSP).
    -- When this list is empty (the default), it always evaluates to `true`.
    -- Note that this is called each time Minuet attempts to trigger
    -- auto-completion, so ensure the functions in this list are highly efficient.
    enable_predicates = {},
    provider_options = {
      -- see the documentation in each provider in the following part.
      openai_fim_compatible = {
        model = 'huggingface.co/unsloth/qwen3-coder-30b-a3b-instruct-gguf:UD-Q4_K_XL',
        stream = true,
        end_point = 'http://localhost:12434/v1/completions',
        api_key = 'TERM',
        name = 'DMR',
        optional = {
          stop = nil, -- { '\n\n' }
          max_tokens = 4092,
          temperature = 0.7,
          min_p = 0.0,
          top_p = 0.8,
          top_k = 20,
          repeat_penalty = 1.05,
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
    -- Config options for `Minuet change_preset` command
    presets = {}
  })
```
