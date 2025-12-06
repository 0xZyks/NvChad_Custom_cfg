-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   comments_block.lua                                 :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: tsignori <tsignori@student.42perpignan.fr  +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/12/05 22:02:34 by tsignori          #+#    #+#             --
--   Updated: 2025/12/06 05:04:28 by tsignori         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --
-- ~/.config/nvim/lua/comment_block.lua

local M = {}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function escape_pattern(s)
  return s:gsub("(%W)", "%%%1")
end

-- Choix des block-comments selon le filetype
local function get_block_markers(ft)
  if ft == "lua" then
    return { open = "--[[", close = "]]" }
  end

  local c_like = {
    c = true,
    cpp = true,
    objc = true,
    cs = true,
    java = true,
    javascript = true,
    typescript = true,
    tsx = true,
    jsx = true,
    css = true,
    scss = true,
  }

  if c_like[ft] then
    return { open = "/*", close = "*/" }
  end

  -- Pas de block-comment pour ce langage → on fera du line-comment
  return nil
end

local function get_line(bufnr, lnum)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if lnum < 0 or lnum >= line_count then
    return nil
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)
  return lines[1]
end

-- === BLOCK COMMENT ===
-- start_line, end_line sont en 0-based ici
local function toggle_block_comment(bufnr, start_line, end_line, markers)
  local open_pat  = "^%s*" .. escape_pattern(markers.open) .. "%s*$"
  local close_pat = "^%s*" .. escape_pattern(markers.close) .. "%s*$"

  local function is_open(s)
    return s and s:match(open_pat)
  end
  local function is_close(s)
    return s and s:match(close_pat)
  end

  local sel_first = get_line(bufnr, start_line)
  local sel_last  = get_line(bufnr, end_line)
  local prev_line = get_line(bufnr, start_line - 1)
  local next_line = get_line(bufnr, end_line + 1)

  -- 🧹 Cas 1 : la sélection INCLUT déjà le bloc complet
  -- /*        <-- start_line
  --  code
  -- */        <-- end_line
  if is_open(sel_first) and is_close(sel_last) and end_line > start_line then
    -- On garde seulement les lignes "intérieures"
    local inner_lines = {}
    if end_line - start_line > 1 then
      inner_lines = vim.api.nvim_buf_get_lines(bufnr, start_line + 1, end_line, false)
    end
    vim.api.nvim_buf_set_lines(bufnr, start_line, end_line + 1, false, inner_lines)
    return
  end

  -- 🧹 Cas 2 : la sélection est le code SEUL, encadré par open/close
  -- /*        <-- start_line - 1
  --  code    <-- [start_line..end_line]
  -- */        <-- end_line + 1
  if is_open(prev_line) and is_close(next_line) then
    -- On supprime d'abord la ligne du bas
    vim.api.nvim_buf_set_lines(bufnr, end_line + 1, end_line + 2, false, {})
    -- Puis celle du haut
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, start_line, false, {})
    return
  end

  -- ➕ Cas 3 : rien de tout ça → on AJOUTE un bloc
  -- On commente en entourant la sélection:
  -- open
  --  <sel>
  -- close
  local sel_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
  local new_lines = {}

  table.insert(new_lines, markers.open)
  for _, l in ipairs(sel_lines) do
    table.insert(new_lines, l)
  end
  table.insert(new_lines, markers.close)

  vim.api.nvim_buf_set_lines(bufnr, start_line, end_line + 1, false, new_lines)
end

-- === LINE COMMENT: utilise 'commentstring' ligne par ligne ===
local function toggle_line_comment(bufnr, start_line, end_line)
  local cs = vim.api.nvim_buf_get_option(bufnr, "commentstring")
  local ft = vim.bo.filetype

  -- Fallback pour shell si commentstring un peu nul
  if (not cs or cs == "" or not cs:find("%%s")) and (ft == "sh" or ft == "bash" or ft == "zsh") then
    cs = "# %s"
  end

  if not cs or cs == "" or not cs:find("%%s") then
    return
  end

  local before, after = cs:match("^(.*)%%s(.*)$")
  before, after = before or "", after or ""

  local prefix = trim(before)
  if prefix == "" then
    prefix = before
  end
  if prefix == "" then
    return
  end

  local esc_prefix = escape_pattern(prefix)
  local esc_after = after ~= "" and escape_pattern(after) or nil

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line + 1, false)

  local all_commented = true
  for _, line in ipairs(lines) do
    if not line:match("^%s*$") then
      if not line:match("^%s*" .. esc_prefix) then
        all_commented = false
        break
      end
    end
  end

  if all_commented then
    -- 🔁 Dé-commenter
    for i, line in ipairs(lines) do
      line = line:gsub("^%s*" .. esc_prefix .. "%s?", "", 1)
      if esc_after then
        line = line:gsub("%s*" .. esc_after .. "%s*$", "", 1)
      end
      lines[i] = line
    end
  else
    -- 🔁 Commenter
    for i, line in ipairs(lines) do
      if not line:match("^%s*$") then
        local new = prefix .. " " .. line
        if after ~= "" then
          new = new .. after
        end
        lines[i] = new
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, start_line, end_line + 1, false, lines)
end

-- === FONCTION PUBLIQUE: start/end en 1-based (venant du mapping) ===
function M.toggle_block_comment(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- 0-based pour l'API
  start_line = start_line - 1
  end_line = end_line - 1

  local ft = vim.bo.filetype
  local markers = get_block_markers(ft)

  if markers then
    toggle_block_comment(bufnr, start_line, end_line, markers)
  else
    toggle_line_comment(bufnr, start_line, end_line)
  end
end

return M
