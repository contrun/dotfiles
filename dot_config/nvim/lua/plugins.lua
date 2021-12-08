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
    use {'wbthomason/packer.nvim', opt = true}

    -- Formatting
    use 'shoukoo/commentary.nvim'
    use 'junegunn/vim-easy-align'
    use 'sbdchd/neoformat'

    -- Themes
    use 'folke/tokyonight.nvim'
    use 'marko-cerovac/material.nvim'

    -- use 'airblade/vim-gitgutter'  -- The standard one I use
    -- Trying out gitsigns
    use({
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = function() require('gitsigns').setup() end
    })

    -- LSP server
    use({
        'neovim/nvim-lspconfig',
        config = function() require('plugins.lspconfig') end
    })
    use 'williamboman/nvim-lsp-installer' -- Helper for installing most language servers

    -- Autocomplete
    use "L3MON4D3/LuaSnip" -- Snippet engine

    use({
        "hrsh7th/nvim-cmp",
        -- Sources for nvim-cmp
        requires = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua", "saadparwaiz1/cmp_luasnip"
        },
        config = function() require('plugins.cmp') end
    })

    -- bufferline
    use({
        'akinsho/nvim-bufferline.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require('plugins.bufferline') end,
        event = 'BufWinEnter'
    })

    -- statusline
    use({
        'hoob3rt/lualine.nvim',
        config = function() require('plugins.lualine') end
    })

    use {'lambdalisue/suda.vim'}

    -- NvimTree
    use({
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require('plugins.nvimtree') end -- Must add this manually
    })

    -- Treesitter
    use({
        'nvim-treesitter/nvim-treesitter',
        config = function() require('plugins.treesitter') end,
        run = ':TSUpdate'
    })

    use {
        'nvim-orgmode/orgmode',
        config = function() require('plugins.orgmode') end
    }

    -- Telescope
    use({
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/plenary.nvim'}},
        config = function() require('plugins.telescope') end
    })

    use({'nvim-telescope/telescope-fzf-native.nvim', run = 'make'})

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

    use({
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
                    enable_default_keybindings = true
                },
                resize = {
                    -- enables default keybindings (A-hjkl) for normal mode
                    enable_default_keybindings = true
                }
            })
        end
    })

    use {
        "blackCauldron7/surround.nvim",
        config = function()
            require"surround".setup {mappings_style = "sandwich"}
        end
    }

    use {
        'TimUntersberger/neogit',
        requires = {'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim'},
        config = function() require('plugins.neogit') end
    }

    -- use {'conweller/findr.vim'}
    -- Waiting for https://github.com/conweller/findr.vim/pull/29
    use {'contrun/findr.vim'}

    use {
        'rmagatti/auto-session',
        config = function()
            require('auto-session').setup {
                log_level = 'debug',
                auto_session_suppress_dirs = {'~/', '~/Workspace/'}
            }
        end
    }

    use {
        'rmagatti/session-lens',
        requires = {'rmagatti/auto-session', 'nvim-telescope/telescope.nvim'},
        config = function()
            require('session-lens').setup({ --[[your custom config--]] })
        end
    }

    if packer_bootstrap then require('packer').sync() end
end)
