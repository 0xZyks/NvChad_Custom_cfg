-- ~/.config/nvim/lua/mappings.lua

require "nvchad.mappings"

local map = vim.keymap.set

---------------------------------------------------------------------
-- <leader>a : indent (=) + alignement 42 (tabs uniquement)
---------------------------------------------------------------------
local function align_42()
  -- Doit être appelé en mode visuel
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return
  end

  -- Limites de la sélection
  local srow = vim.fn.getpos("'<")[2]
  local erow = vim.fn.getpos("'>")[2]
  if srow > erow then srow, erow = erow, srow end

  local bufnr = 0

  --------------------------------------------------------------------
  -- 1) Réindentation standard (== sur chaque ligne)
  --------------------------------------------------------------------
  vim.cmd(string.format("%d,%dnormal! ==", srow, erow))

  --------------------------------------------------------------------
  -- 2) Alignement style 42 : type<TABS>name
  --------------------------------------------------------------------
  local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)

  local decl = {}
  local max_type_len = 0

  local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- On évite de traiter "return", "goto", etc. comme des types
  local skip_kw = {
    ["return"] = true,
    ["goto"]   = true,
  }

  -- 1ère passe : détecter les déclarations & calculer la longueur max du type
  for i, line in ipairs(lines) do
    local indent, body = line:match("^(%s*)(.*)$")
   ---------------------------------------------------------------------
-- <leader>a : indent (=) + alignement 42 (tabs uniquement)
---------------------------------------------------------------------
local function align_42()
  -- Doit être appelé en mode visuel
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return
  end

  -- Limites de la sélection
  local srow = vim.fn.getpos("'<")[2]
  local erow = vim.fn.getpos("'>")[2]
  if srow > erow then srow, erow = erow, srow end

  local bufnr = 0

  --------------------------------------------------------------------
  -- 1) Réindentation standard (== sur chaque ligne)
  --------------------------------------------------------------------
  vim.cmd(string.format("%d,%dnormal! ==", srow, erow))

  --------------------------------------------------------------------
  -- 2) Alignement style 42 : type<TABS>name
  --------------------------------------------------------------------
  local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)

  local decl = {}
  local max_type_len = 0

  local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- On évite de traiter "return", "goto", etc. comme des types
  local skip_kw = {
    ["return"] = true,
    ["goto"]   = true,
  }

  -- 1ère passe : détecter les déclarations & calculer la longueur max du type
  for i, line in ipairs(lines) do
    local indent, body = line:match("^(%s*)(.*)$")
    if body:match("%S") then
      -- On cherche : type_part  name  (  ou  ;
      -- type_part peut contenir des espaces (long long, unsigned int, ...)
      local type_part, name, delim, rest =
        body:match("^(.-)([_%a][_%w]*)%s*([%(;])(.*)$")

      if type_part and name and delim then
        local ttrim = trim(type_part)

        if not skip_kw[ttrim] then
          -- On enlève les espaces en fin de type
          local clean_type = ttrim

          -- Déplacer les * éventuels vers le nom (style 42 : char    *str)
          local star_part = clean_type:match("%*+$")
          if star_part then
            clean_type = clean_type:sub(1, #clean_type - #star_part)
            name = star_part .. name
          end

          local type_len = #clean_type

          if type_len > max_type_len then
            max_type_len = type_len
          end

          decl[i] = {
            indent    = indent,
            type_part = clean_type,
            type_len  = type_len,
            name      = name,
            tail      = delim .. (rest or ""),
          }
        end
      end
    end
  end

  -- S'il n'y a aucune déclaration, on ne touche plus aux lignes
  if vim.tbl_isempty(decl) then
    return
  end

  --------------------------------------------------------------------
  -- 3) Réécriture style 42 : type + tabs + name
  --------------------------------------------------------------------
  for i, data in pairs(decl) do
    -- Nombre de tabs : plus le type est court, plus on ajoute de tabs
    local tabs_count = (max_type_len - data.type_len) + 1
    if tabs_count < 1 then
      tabs_count = 1
    end

    local tabs = string.rep("\t", tabs_count)
    lines[i] = data.indent .. data.type_part .. tabs .. data.name .. data.tail
  end

  vim.api.nvim_buf_set_lines(bufnr, srow - 1, erow, false, lines)
end if body:match("%S") then
      -- On cherche : type_part  name  (  ou  ;
      -- type_part peut contenir des espaces (long long, unsigned int, ...)
      local type_part, name, delim, rest =
        body:match("^(.-)([_%a][_%w]*)%s*([%(;])(.*)$")

      if type_part and name and delim then
        local ttrim = trim(type_part)

        if not skip_kw[ttrim] then
          -- On enlève les espaces en fin de type
          local clean_type = ttrim

          -- Déplacer les * éventuels vers le nom (style 42 : char    *str)
          local star_part = clean_type:match("%*+$")
          if star_part then
            clean_type = clean_type:sub(1, #clean_type - #star_part)
            name = star_part .. name
          end

          local type_len = #clean_type

          if type_len > max_type_len then
            max_type_len = type_len
          end

          decl[i] = {
            indent    = indent,
            type_part = clean_type,
            type_len  = type_len,
            name      = name,
            tail      = delim .. (rest or ""),
          }
        end
      end
    end
  end

  -- S'il n'y a aucune déclaration, on ne touche plus aux lignes
  if vim.tbl_isempty(decl) then
    return
  end

  --------------------------------------------------------------------
  -- 3) Réécriture style 42 : type + tabs + name
  --------------------------------------------------------------------
  for i, data in pairs(decl) do
    -- Nombre de tabs : plus le type est court, plus on ajoute de tabs
    local tabs_count = (max_type_len - data.type_len) + 1
    if tabs_count < 1 then
      tabs_count = 1
    end

    local tabs = string.rep("\t", tabs_count)
    lines[i] = data.indent .. data.type_part .. tabs .. data.name .. data.tail
  end

  vim.api.nvim_buf_set_lines(bufnr, srow - 1, erow, false, lines)
end

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
map("n", "<leader>tv", "<cmd>ToggleTerm size=50 direction=vertical<CR>", { desc = "Terminal vertical" })
-- Raccourci pour revenir au mode normal depuis un terminal-
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
---------------------------------------------------------------------
-- Nouveau mapping : alignement smart du bloc
---------------------------------------------------------------------

-- SPACE + a en VISUEL
map("v", "<F2>", align_42, { desc = "Indent + 42-align declarations" })

-- Si un jour tu règles ton terminal pour <S-Tab>, tu peux aussi faire :
-- map("v", "<S-Tab>", smart_align_block, { desc = "Smart indent + align declarations" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil file explorer" })
