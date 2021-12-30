local lsp_config = require('lspconfig')
local lsp_installer = require("nvim-lsp-installer")
local lsp_utils = require('lsp.utils')

local common_on_attach = lsp_utils.common_on_attach
-- add capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {on_attach = common_on_attach, capabilities = capabilities}

    -- Now we'll create a server_opts table where we'll specify our custom LSP server configuration
    local server_opts = {
        -- Provide settings that should only apply to the "eslintls" server
        ["eslintls"] = function()
            opts.settings = {format = {enable = true}}
        end
    }

    -- Use the server's custom settings, if they exist, otherwise default to the default options
    local server_options = server_opts[server.name] and
                               server_opts[server.name]() or opts
    server:setup(server_options)
end)

local lsp_installer_servers = {
    "bashls", "clangd", "pyright", "jsonls", "dockerls", "rust_analyzer", "hls",
    "tsserver", "elixirls", "jdtls", "zls", "metals", "gopls", "texlab",
    "sumneko_lua"
}

for _, name in pairs(lsp_installer_servers) do
    local server_is_found, server = lsp_installer.get_server(name)
    if server_is_found then
        if not server:is_installed() then server:install() end
    end
end

local other_servers = {
    "metals"
}

for _, server in ipairs(other_servers) do
    lsp_config[server].setup({
        on_attach = common_on_attach,
        capabilities = capabilities
    })
end

require('lsp.sumneko')
