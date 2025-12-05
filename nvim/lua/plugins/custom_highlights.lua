-- ~/.config/nvim/plugin/custom_highlights.lua

local function set_custom_highlights()
  ---------------------------------------------------------------------------
  -- VARIABLES (nom de variable, genre "str" dans "char *str;")
  ---------------------------------------------------------------------------
  -- Treesitter : variables locales/globales
  vim.api.nvim_set_hl(0, "@variable", { fg = "#ffb86c" })
  vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#ffb86c" })
  vim.api.nvim_set_hl(0, "@variable.member", { fg = "#ffb86c" })

  -- LSP semantic tokens : variables
  vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = "#ffb86c" })
  vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = "#ffb86c" })

  ---------------------------------------------------------------------------
  -- CHAMPS / PROPRIÉTÉS (player.hp, obj.Field, etc.)
  ---------------------------------------------------------------------------
  vim.api.nvim_set_hl(0, "@field", { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "@property", { fg = "#7aa2f7" })

  vim.api.nvim_set_hl(0, "@lsp.type.field", { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = "#7aa2f7" })
end

-- Appliquer au démarrage
set_custom_highlights()

-- Ré-appliquer si tu changes de colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_custom_highlights,
})

return {}
