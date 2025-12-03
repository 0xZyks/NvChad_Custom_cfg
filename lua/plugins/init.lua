return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
	  require "nvchad.configs.lspconfig"
      require "configs.lspconfig"
    end,
  },

	-- lsp_signature: affiche les paramètres quand tu tapes "("
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				floating_window = true,
				hint_enable = true,
				hi_parameter = "IncSearch",
				handler_opts = {
					border = "rounded",
				},
			})
		end,
	},

  {
    "stevearc/oil.nvim",
    lazy = false, -- recommandé, sinon ça peut être chiant à init dans tous les cas
    opts = {
      default_file_explorer = true, -- remplace netrw pour `nvim .`
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      view_options = {
        show_hidden = true, -- si tu veux voir les fichiers cachés
      },
    },
    -- pour les icônes, choisis UN des deux:
    dependencies = {
      -- { "nvim-tree/nvim-web-devicons" }, -- si tu as déjà ça, ok
      { "nvim-mini/mini.icons", opts = {} }, -- sinon mini.icons marche très bien
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
