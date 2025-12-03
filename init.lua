vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Numéros relatifs
vim.opt.number = true        -- numéro absolu
vim.opt.relativenumber = true -- numéro relatif

-- Indentation
vim.opt.tabstop = 4        -- 1 tab = 4 espaces visuellement
vim.opt.shiftwidth = 4     -- indentation automatique = 4
vim.opt.expandtab = false  -- garde les vrais tabs (norme 42 exige TAB)
vim.opt.softtabstop = 4    -- comportement du tab

-- Auto indentation
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Tab View
vim.opt.list = true
vim.opt.listchars = { tab = '→ ' }

vim.g.user42 = "tsignori"
vim.g.mail42 = "tsignori@student.42perpignan.fr"

