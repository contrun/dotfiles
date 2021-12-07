-- LSP helper function
local cmd = vim.cmd

local M = {}

cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

-- This function defines the on_attach function for several languages which share the same key-bidings
function M.common_on_attach(client, bufnr)
    -- Set omnifunc
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Helper function
    local opts = {noremap = true, silent = true}
    local function bufnnoremap(lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
    end

    -- Keymaps: we need to define keymaps for each of the LSP functionalities manually
    -- Go to definition and declaration (use leader to presever standard use of 'gd')
    bufnnoremap("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
    bufnnoremap("gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")

    -- Go to implementation
    bufnnoremap("gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>")

    -- List symbol uses
    bufnnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>") -- Uses quickfix
    -- bufnnoremap("gr", "<cmd>Telescope lsp_references<CR>")  -- Uses Telescope

    -- Rename all references of symbol
    bufnnoremap("gR", "<Cmd>lua vim.lsp.buf.rename()<CR>")

    -- Inspect function
    bufnnoremap("K", "<Cmd>lua vim.lsp.buf.hover()<CR>")

    -- Signature help
    bufnnoremap("<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")

    if client.resolved_capabilities.document_formatting then
        cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

return M
