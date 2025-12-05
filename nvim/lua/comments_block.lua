-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   comments_block.lua                                 :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: tsignori <tsignori@student.42perpignan.fr  +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/12/05 22:02:34 by tsignori          #+#    #+#             --
--   Updated: 2025/12/05 22:16:24 by tsignori         ###   ########.fr       --
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

-- Détermine si on doit utiliser un block-comment ou des commentaires par ligne
local function get_block_markers(ft)
  -- Lua : block style --[[ ... ]]
  if ft == "lua" then
    return { open = "--[[", close = "]]" }
  end

  -- Langages style C / C# / Java / JS / TS...
  local c_like = {
    c = true,
    cpp = true,
    objc = true,
    cs = true,
    java = true,
    javascript = true,
    typescript = true,
    css = true,
    scss = true,
  }

  if c_like[ft] then
    return { open = "/*", close = "*/" }
  end

  -- Sinon : pas de block marker → on fera des commentaires par ligne
  return nil
end

local function toggle_block_comment(bufnr, start_line, end_line, markers)
  local function get_line(lnum)
    local lines = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)
    return lines[1]
  end

  local prev_line = nil
  if start_line - 1 >= 0 then
    prev_line = get_line(start_line - 1)
  end
  local next_line = get_line(end_line + 1)

  local open_pat = "^%s*" .. escape_pattern(markers.open) .. "%s*$"
  local close_pat = "^%s*" .. escape_pattern(markers.close) .. "%s*$"

  local function is_open_block(s)
    return s and s:match(open_pat)
  end

  local function is_close_block(s)
    return s and s:match(close_pat)
  end

  if is_open_block(prev_line) and is_close_block(next_line) then
    -- 🔁 Dé-commenter : supprime les lignes avec open/close
    vim.api.nvim_buf_set_lines(bufnr, end_line + 1, end_line + 2, false, {})
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, start_line, false, {})
  else
    -- 🔁 Commenter : ajoute open avant et close après
    vim.api.nvim_buf_set_lines(bufnr, end_line + 1, end_line + 1, false, { markers.close })
    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line, false, { markers.open })
  end
end

local function toggle_line_comment(bufnr, start_line, end_line)
  -- On récupère le commentstring du buffer, ex: "// %s", "# %s", "-- %s", etc.
  local cs = vim.api.nvim_buf_get_option(bufnr, "commentstring")
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

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)

  -- Vérifier si TOUTES les lignes non vides sont déjà commentées
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
      -- enlève le prefix au début (+ éventuel espace suivant)
      line = line:gsub("^%s*" .. esc_prefix .. "%s?", "", 1)
      -- enlève éventuellement le suffixe (after) en fin de ligne
      if esc_after then
        line = line:gsub("%s*" .. esc_after .. "%s*$", "", 1)
      end
      lines[i] = line
    end
  else
    -- 🔁 Commenter
    for i, line in ipairs(lines) do
      if line:match("^%s*$") then
        -- ligne vide → on la laisse vide
      else
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

function M.toggle_block_comment_visual()
  local bufnr = vim.api.nvim_get_current_buf()

  -- On vérifie qu'on est en mode visuel
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\022" then
    return
  end

  -- Récupère les positions de la sélection ('< et '>)
  local _, start_line, _, _ = unpack(vim.fn.getpos("'<"))
  local _, end_line, _, _ = unpack(vim.fn.getpos("'>"))

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- passage en 0-based
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
