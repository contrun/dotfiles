local lsp_config = require('lspconfig')
local lsp_installer = require("nvim-lsp-installer")
local lsp_utils = require('lsp.utils')

local common_on_attach = lsp_utils.common_on_attach
-- add capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local get_option_for_server = function(server)
    local default = {on_attach = common_on_attach, capabilities = capabilities}

    -- Now we'll create a server_default table where we'll specify our custom LSP server configuration
    local overrides = {
        -- Provide settings that should only apply to the "eslintls" server
        ["eslintls"] = function()
            default.settings = {format = {enable = true}}
            return default
        end,
        ["omnisharp"] = function()
            local pid = vim.fn.getpid()
            local omnisharp_bin = "omnisharp"
            default.cmd = {
                omnisharp_bin, "--languageserver", "--hostPID", tostring(pid)
            }
            return default
        end
    }
    return overrides[server] and overrides[server]() or default
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    server:setup(get_option_for_server(server.name))
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

local other_servers = {"metals", "rnix", "gopls", "omnisharp"}

for _, server in ipairs(other_servers) do
    lsp_config[server].setup(get_option_for_server(server))
end

require('lsp.sumneko')
