-- Plugin definition and loading
local execute = vim.api.nvim_command
local fn = vim.fn
local cmd = vim.cmd

-- Boostrap Packer
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
    'git', 'clone', 'https://github.com/wbthomason/packer.nvim',
    install_path
  })
end

-- Rerun PackerCompile everytime pluggins.lua is updated
cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- Load Packer
cmd [[packadd packer.nvim]]

-- Initialize pluggins
return require('packer').startup(function(use)
  -- Let Packer manage itself
  use { 'wbthomason/packer.nvim', opt = true }

  -- Formatting
  use 'shoukoo/commentary.nvim'
  use 'sbdchd/neoformat'
  use {
    'lukas-reineke/lsp-format.nvim',
    config = function() require("lsp-format").setup {} end
  }

  -- Easier navigation
  use 'junegunn/vim-easy-align'
  use 'andymass/vim-matchup'

  -- Themes
  use 'folke/tokyonight.nvim'
  use 'marko-cerovac/material.nvim'

  use 'ryvnf/readline.vim'

  -- use 'airblade/vim-gitgutter'  -- The standard one I use
  -- Trying out gitsigns
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  -- LSP server
  use {
    'neovim/nvim-lspconfig',
    config = function() require('plugins.lspconfig') end
  }
  use 'williamboman/nvim-lsp-installer' -- Helper for installing most language servers
  -- use({'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" }})

  use {
    'onsails/lspkind.nvim',
    config = function()
      require('lspkind').init {
        mode = 'symbol_text',
        preset = 'codicons',
      }
    end
  }

  use {
    'mfussenegger/nvim-dap',
    requires = {
      "Pocco81/dap-buddy.nvim", "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap-python",
      "mfussenegger/nvim-jdtls", "nvim-telescope/telescope-dap.nvim",
      { "leoluz/nvim-dap-go" }, { "jbyuki/one-small-step-for-vimkind" }
    },
    config = function() require('plugins.dapconfig') end
  }

  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }

  use {
    "theHamsta/nvim-dap-virtual-text",
    requires = { "mfussenegger/nvim-dap" }
  }

  -- Autocomplete
  use "L3MON4D3/LuaSnip" -- Snippet engine

  use "liuchengxu/vista.vim"

  use {
    "hrsh7th/nvim-cmp",
    -- Sources for nvim-cmp
    requires = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua", "saadparwaiz1/cmp_luasnip"
    },
    config = function() require('plugins.cmp') end
  }

  -- bufferline
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require('plugins.bufferline') end,
    event = 'BufWinEnter'
  }

  -- statusline
  use {
    'hoob3rt/lualine.nvim',
    config = function() require('plugins.lualine') end
  }

  use { 'lambdalisue/suda.vim' }

  -- NvimTree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require('plugins.nvimtree') end -- Must add this manually
  }

  use { 'wakatime/vim-wakatime' }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    config = function() require('plugins.treesitter') end,
    run = ':TSUpdate'
  }

  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require 'nvim-treesitter.configs'.setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner"
            }
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>sa"] = "@parameter.inner" },
            swap_previous = { ["<leader>sA"] = "@parameter.inner" }
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer"
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer"
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer"
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer"
            }
          },
          lsp_interop = {
            enable = true,
            border = 'none',
            peek_definition_code = {
              ["<leader>lf"] = "@function.outer",
              ["<leader>lF"] = "@class.outer"
            }
          }
        }
      }
    end
  }

  -- TODO: fix
  -- packer.nvim: Error running config for nvim-treesitter-textobjects: ...ed-0.6.1/share/nvim/runtime/lua/vim/treesitter/query.lua:161: query: invalid node type at position 13
  use {
    "mizlan/iswap.nvim",
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('iswap').setup {
        -- The keys that will be used as a selection, in order
        -- ('asdfghjklqwertyuiopzxcvbnm' by default)
        keys = 'qwertyuiop',

        -- Grey out the rest of the text when making a selection
        -- (enabled by default)
        grey = 'disable',

        -- Highlight group for the sniping value (asdf etc.)
        -- default 'Search'
        hl_snipe = 'ErrorMsg',

        -- Highlight group for the visual selection of terms
        -- default 'Visual'
        hl_selection = 'WarningMsg',

        -- Highlight group for the greyed background
        -- default 'Comment'
        hl_grey = 'LineNr',

        -- Automatically swap with only two arguments
        -- default nil
        autoswap = true,

        -- Other default options you probably should not change:
        debug = nil,
        hl_grey_priority = '1000'
      }
    end
  }

  -- TODO: fix
  -- Failed to get context: ...ed-0.6.1/share/nvim/runtime/lua/vim/treesitter/query.lua:161: query: invalid field at position 18
  -- use {
  --     "romgrk/nvim-treesitter-context",
  --     config = function()
  --         require'treesitter-context'.setup {
  --             enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  --             throttle = true, -- Throttles plugin updates (may improve performance)
  --             max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  --             patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
  --                 -- For all filetypes
  --                 -- Note that setting an entry here replaces all other patterns for this entry.
  --                 -- By setting the 'default' entry below, you can control which nodes you want to
  --                 -- appear in the context window.
  --                 default = {
  --                     'class', 'function', 'method'
  --                     -- 'for', -- These won't appear in the context
  --                     -- 'while',
  --                     -- 'if',
  --                     -- 'switch',
  --                     -- 'case',
  --                 },
  --                 -- Example for a specific filetype.
  --                 -- If a pattern is missing, *open a PR* so everyone can benefit.
  --                 rust = {'impl_item'}
  --             },
  --             exact_patterns = {
  --                 -- Example for a specific filetype with Lua patterns
  --                 -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
  --                 -- exactly match "impl_item" only)
  --                 -- rust = true,
  --             }
  --         }
  --     end
  -- }

  use {
    'nvim-orgmode/orgmode',
    config = function() require('orgmode').setup_ts_grammar() end
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } },
    config = function() require('plugins.telescope') end
  }

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require('neoclip').setup({
        history = 1000,
        enable_persistent_history = false,
        length_limit = 1048576,
        continuous_sync = false,
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
        filter = nil,
        preview = true,
        default_register = '"',
        default_register_macros = 'q',
        enable_macro_history = true,
        content_spec_column = false,
        on_paste = { set_reg = false },
        on_replay = { set_reg = false },
        keys = {
          telescope = {
            i = {
              select = '<cr>',
              paste = '<c-p>',
              paste_behind = '<c-k>',
              replay = '<c-q>', -- replay a macro
              delete = '<c-d>', -- delete an entry
              custom = {}
            },
            n = {
              select = '<cr>',
              paste = 'p',
              paste_behind = 'P',
              replay = 'q',
              delete = 'd',
              custom = {}
            }
          },
          fzf = {
            select = 'default',
            paste = 'ctrl-p',
            paste_behind = 'ctrl-k',
            custom = {}
          }
        }
      })
    end
  }
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  use {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup({
        -- overwrite default configuration
        -- here, e.g. to enable default bindings
        copy_sync = {
          -- enables copy sync and overwrites all register actions to
          -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
          enable = true
        },
        navigation = {
          -- enables default keybindings (C-hjkl) for normal mode
          enable_default_keybindings = false
        },
        resize = {
          -- enables default keybindings (A-hjkl) for normal mode
          enable_default_keybindings = false
        }
      })
    end
  }

  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- https://github.com/rockerBOO/awesome-neovim/issues/315
  use {
    "ur4ltz/surround.nvim",
    config = function()
      require "surround".setup { mappings_style = "sandwich" }
    end
  }

  use {
    'TimUntersberger/neogit',
    requires = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    config = function() require('plugins.neogit') end
  }

  use { 'conweller/findr.vim' }

  use {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup {
        log_level = 'debug',
        auto_session_suppress_dirs = { '~/', '~/Workspace/', '/tmp/' }
      }
    end
  }

  use {
    'rmagatti/session-lens',
    requires = { 'rmagatti/auto-session', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('session-lens').setup({ --[[your custom config--]] })
    end
  }

  if packer_bootstrap then require('packer').sync() end
end)
