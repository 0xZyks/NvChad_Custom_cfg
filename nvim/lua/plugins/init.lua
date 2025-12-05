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
		lazy = false,
		opts = {
			default_file_explorer = true,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				-- garder les classiques si tu veux
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = "actions.select_vsplit",
				["<C-h>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				-- ce qui nous intéresse :
				["-"] = "actions.close",      -- dans Oil: '-' ferme le bufferline
				["<BS>"] = "actions.parent",  -- backspace pour remonter d'un dossier--
				-- tu peux aussi garder d'autres si tu veux
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["g."] = "actions.toggle_hidden",
			},
		},
		dependencies = {
			{ "nvim-mini/mini.icons", opts = {} },
			-- ou "nvim-tree/nvim-web-devicons" si tu préfère
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
