require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<F1>", function()
  if vim.api.nvim_buf_line_count(0) <= 1 then
    vim.cmd("Stdheader")
  end
end, { desc = "Add 42 Header" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
