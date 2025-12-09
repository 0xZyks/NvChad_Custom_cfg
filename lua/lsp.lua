-- -------------------------------------------------------------------------- --
--                                                                            --
--                                                        :::      ::::::::   --
--   lsp.lua                                            :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: tsignori <tsignori@student.42perpignan.fr  +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2025/12/03 21:34:21 by tsignori          #+#    #+#             --
--   Updated: 2025/12/03 21:35:19 by tsignori         ###   ########.fr       --
--                                                                            --
-- -------------------------------------------------------------------------- --

local M = {}

M.on_attach = function(client, bufnr)
  -- Raccourci pour afficher la signature à la demande
  vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, {
    buffer = bufnr,
    desc = "LSP Signature Help",
  })
end

return M

