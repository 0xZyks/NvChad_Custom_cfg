-- ~/.config/nvim/lua/configs/lspconfig.lua

-- Config de base NvChad (mappings, capabilities, etc.)
local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.defaults()

-- On applique les callbacks NvChad à TOUS les serveurs
vim.lsp.config("*", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
})

-- Liste des serveurs que tu veux
local servers = { "html", "cssls", "clangd" }

-- Config spécifique pour clangd (options en plus)
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  -- tu peux ajouter root_markers, filetypes, etc. ici si tu veux
})

-- Et on les active
vim.lsp.enable(servers)
