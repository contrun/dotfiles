local Utils = require('utils')

-- local exprnnoremap = Utils.exprnnoremap
local nnoremap = Utils.nnoremap
local vnoremap = Utils.vnoremap
-- local xnoremap = Utils.xnoremap
local inoremap = Utils.inoremap
-- local tnoremap = Utils.tnoremap
-- local nmap = Utils.nmap
-- local xmap = Utils.xmap

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- kj to normal mode
inoremap("kj", "<Esc>")

-- Run omnifunc, mostly used for autocomplete
inoremap("<C-SPACE>", "<C-x><C-o>")

-- Save with Ctrl + S
nnoremap("<C-s>", "<Cmd>w<CR>")

-- Close buffer
nnoremap("<A-z>", "<Cmd>q<CR>")

nnoremap("[b", "<Cmd>bprevious<CR>")
nnoremap("]b", "<Cmd>bnext<CR>")

nnoremap("<C-[>", "<Cmd>bprevious<CR>")
nnoremap("<C-]>", "<Cmd>bnext<CR>")

-- Delete buffer
nnoremap("<A-w>", "<Cmd>bd<CR>")
nnoremap("<C-w>d", "<Cmd>bd<CR>")
nnoremap("<C-w><C-d>", "<Cmd>bd<CR>")

-- Yank to end of line
nnoremap("Y", "y$")

-- Copy to system clippboard
nnoremap("<leader>y", '"+y')
vnoremap("<leader>y", '"+y')

-- Paste from system clippboard
nnoremap("<leader>p", '"+p')
vnoremap("<leader>p", '"+p')

-- Local list
nnoremap("<leader>ll", "<Cmd>lopen<CR>")
nnoremap("<leader>lc", "<Cmd>lclose<CR>")
nnoremap("<leader>ln", "<Cmd>lnext<CR>")
nnoremap("<leader>lp", "<Cmd>lprev<CR>")

-- Quickfix list
nnoremap("<leader>ql", "<Cmd>copen<CR>")
nnoremap("<leader>qc", "<Cmd>cclose<CR>")
nnoremap("<leader>qn", "<Cmd>cnext<CR>")
nnoremap("<leader>qp", "<Cmd>cprev<CR>")

nnoremap("<leader>xo", "<Cmd> !xdg-open %<CR><CR>")
nnoremap("<leader>xs", "<Cmd>source $MYVIMRC<CR>")
nnoremap("<leader>xp", "<Cmd>PackerSync<CR>")

nnoremap("<leader>g", "<Cmd>Neogit<CR>")

-- Show line diagnostics
nnoremap("<leader>d",
         '<Cmd>lua vim.diagnostic.open_float(0, {scope = "line"})<CR>')

-- Open local diagnostics in local list
nnoremap("<leader>D", "<Cmd>lua vim.diagnostic.setloclist()<CR>")

-- Open all project diagnostics in quickfix list
nnoremap("<leader><A-d>", "<Cmd>lua vim.diagnostic.setqflist()<CR>")

-- Telescope
nnoremap("<leader>f", "<Cmd>Telescope find_files<CR>")
nnoremap("<leader>o", "<Cmd>Telescope oldfiles<CR>")
nnoremap("<leader>b", "<Cmd>Telescope buffers<CR>")
nnoremap("<leader>/", "<Cmd>Telescope live_grep<CR>")

nnoremap("<leader>e", "<Cmd>FindrParentDir<CR>")

nnoremap("<leader>=", "<Cmd>Neoformat<CR>")

-- EasyAlign
vnoremap("ga", "<Cmd>EasyAlign<CR>")
nnoremap("ga", "<Cmd>EasyAlign<CR>")
