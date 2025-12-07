-- ~/.config/nvim/lua/mappings.lua

require "nvchad.mappings"

local map = vim.keymap.set

---------------------------------------------------------------------
-- Tes mappings existants
---------------------------------------------------------------------

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<F1>", function()
  if vim.api.nvim_buf_line_count(0) <= 1 then
    vim.cmd("Stdheader")
  end
end, { desc = "Add 42 Header" })
-- Mapping F3 en VISUAL pour toggle /* ... */
-- VISUAL: F3 -> toggle block comment sur la sélection
vim.keymap.set("v", "<F3>", function()
  local start_line = vim.fn.line("v") -- ligne où le Visual a commencé
  local end_line = vim.fn.line(".")   -- ligne du curseur actuel
  require("comments_block").toggle_block_comment(start_line, end_line)
end, { desc = "Toggle block comment (visual selection)" })
-- Toggle terminal flottant avec Ctrl+\
map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Terminal horizontal
map("n", "<F4>", "<cmd>ToggleTerm size=15 direction=float<CR>", { desc = "Terminal horizontal" })

-- Terminal vertical
map("n", "<F5>", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "Terminal vertical" })
-- Raccourci pour revenir au mode normal depuis un terminal-
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Close current BufferTab
map("n", "<leader>q", "<cmd>bd<CR>", { desc = "Close Current BufferTab"});
---------------------------------------------------------------------
-- Nouveau mapping : alignement smart du bloc
---------------------------------------------------------------------

-- Si un jour tu règles ton terminal pour <S-Tab>, tu peux aussi faire :
-- map("v", "<S-Tab>", smart_align_block, { desc = "Smart indent + align declarations" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil file explorer" })
