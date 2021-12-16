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

    bufnnoremap("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
    bufnnoremap("gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")
    bufnnoremap("gi", "<Cmd>Telescope lsp_implementations<CR>")

    -- List symbol uses
    -- bufnnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>") -- Uses quickfix
    bufnnoremap("gr", "<cmd>Telescope lsp_references<CR>") -- Uses Telescope
    bufnnoremap("gR", "<Cmd>lua vim.lsp.buf.rename()<CR>")
    bufnnoremap("K", "<Cmd>lua vim.lsp.buf.hover()<CR>")
    bufnnoremap("<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")

    bufnnoremap('<leader>lw', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
    bufnnoremap('<leader>lr',
                '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
    bufnnoremap('<leader>lW',
                '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
    bufnnoremap('<leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    bufnnoremap('<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    bufnnoremap('<leader>le', '<cmd>lua vim.diagnostic.open_float()<CR>')
    bufnnoremap('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    bufnnoremap(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    bufnnoremap('<leader>lq', '<cmd>lua vim.diagnostic.setloclist()<CR>')
    bufnnoremap("<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>")
    bufnnoremap("<leader>l/", "<cmd>Telescope lsp_workspace_symbols<CR>")

    if client.resolved_capabilities.document_formatting then
        cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

return M
