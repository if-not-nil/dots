---------------------------------
---         options           ---
---------------------------------

vim.cmd.colorscheme("bark")

-- ui
vim.o.scrolloff = 10
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.pumheight = 15
vim.o.shortmess = "CFOSWaco"

-- completion
vim.o.autocomplete = true
vim.o.completeopt = "menuone,noinsert,popup,fuzzy,nearest"
vim.o.pumheight = 15
vim.o.pummaxwidth = 40

-- search
vim.o.imsearch = 0
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- files / state
vim.o.clipboard = "unnamedplus"
vim.o.langremap = false
vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.opt.shada = { "'10", "<0", "s10", "h" }
vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"

-- indentation
vim.o.expandtab = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true

-- wrapping
vim.o.wrap = true
vim.o.breakindent = true
vim.o.linebreak = true

vim.diagnostic.config({
	virtual_text = { prefix = "" },
	float = { border = "single" },
})

vim.filetype.add({
	extension = {
		h = "c",
		hpp = "cpp",
		vs = "glsl",
		fs = "glsl",
	},
})

require("vim._core.ui2").enable({
	enable = true, -- Whether to enable or disable the UI.
	msg = {       -- Options related to the message module.
		---@type 'cmd'|'msg' Default message target, either in the
		---cmdline or in a separate ephemeral message window.
		---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
		---or table mapping |ui-messages| kinds and triggers to a target.
		targets = "cmd",
		cmd = {        -- Options related to messages in the cmdline window.
			height = 0.5, -- Maximum height while expanded for messages beyond 'cmdheight'.
		},
		dialog = {     -- Options related to dialog window.
			height = 0.5, -- Maximum height.
		},
		msg = {        -- Options related to msg window.
			height = 0.5, -- Maximum height.
			timeout = 4000, -- Time a message is visible in the message window.
		},
		pager = {      -- Options related to message window.
			height = 1,  -- Maximum height.
		},
	},
})

---------------------------------
---         keymaps           ---
---------------------------------
local map = vim.keymap.set
do
	vim.g.mapleader = " "
	vim.g.maplocalleader = "\\"

	vim.cmd("packadd nvim.undotree")
	map("n", "<leader>u", require("undotree").open)

	-- insert mode
	map("i", "<C-a>", "<C-o>^", { noremap = true })
	map("i", "<C-e>", "<C-o>$")
	map("i", "<C-b>", "<Left>")
	map("i", "<C-f>", "<Right>")
	map("i", "<A-b>", "<Esc>bi", { noremap = true })
	map("i", "<A-f>", "<Esc>ea", { noremap = true })

	-- treesitter selection
	map({ "n", "x", "o" }, "<A-o>", function()
		if vim.treesitter.get_parser(nil, nil, { error = false }) then
			require("vim.treesitter._select").select_parent(vim.v.count1)
		else
			vim.lsp.buf.selection_range(vim.v.count1)
		end
	end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

	map({ "n", "x", "o" }, "<A-i>", function()
		if vim.treesitter.get_parser(nil, nil, { error = false }) then
			require("vim.treesitter._select").select_child(vim.v.count1)
		else
			vim.lsp.buf.selection_range(-vim.v.count1)
		end
	end, { desc = "Select child treesitter node or inner incremental lsp selections" })

	-- substitution
	map({ "x", "n" }, "<C-r>", [[<esc>:'<,'>s/]], { desc = "enter substitue mode in selection" })

	-- buffers
	map("n", "<Tab>", "<cmd>e #<CR>")
	map({ "n", "x" }, "<leader>bd", "<cmd>:bd<CR>")
	map({ "n", "x" }, "<leader>bB", "<cmd>:bd!<CR>")
	map({ "n", "x" }, "<leader>bk", "<cmd>:bd<CR>")
	map({ "n", "x" }, "<leader>bK", "<cmd>:bd!<CR>")
	map({ "n", "x" }, "<leader>w", ":w<cr>", { desc = "write buffer" })
	map("n", "<leader>q", ":bd<CR>", { desc = "Close buffer" })
	map("n", "<leader>Q", ":bd!<CR>", { desc = "Force close buffer" })

	-- window resize
	map({ "n", "x" }, "<C-w>,", ":vertical resize -2<CR>", { noremap = true, silent = true })
	map({ "n", "x" }, "<C-w>.", ":vertical resize +2<CR>", { noremap = true, silent = true })
	map({ "n", "x" }, "<C-w>-", ":resize -2<CR>", { noremap = true, silent = true })
	map({ "n", "x" }, "<C-w>=", ":resize +2<CR>", { noremap = true, silent = true })
	map({ "n", "x" }, "<C-w>+", "<C-w>=", { noremap = true, silent = true })

	-- terminal
	map("t", "<Esc>", "<C-\\><C-n>")
	map("t", "<C-[>", "<C-\\><C-n>")
	map("n", "<C-w>e", "<CMD>trm<CR>", { desc = "Terminal" })

	-- spell check
	map("n", "<leader>=", function()
		vim.o.spell = not vim.o.spell
	end, { desc = "toggle spell check" })

	-- movement
	map("n", "<C-d>", "<C-d>zz")
	map("n", "<C-u>", "<C-u>zz")
	map("n", "<C-f>", "<C-f>zz")
	map("n", "<C-b>", "<C-b>zz")

	-- editing
	map({ "n", "x" }, "U", vim.cmd.redo, { desc = "redo" })
	map("v", "J", ":m '>+1<CR>gv=gv")
	map("v", "K", ":m '<-2<CR>gv=gv")
	map("n", "J", "mzJ`z", { desc = "join lines and keep cursor position" })
	map("n", "<Esc>", "<cmd>noh<CR>", { desc = "clear search highlights" })

	-- copy/paste whole buffer
	map("n", "<leader>y", "mkggVGy`k")
	map("n", "<leader>p", "ggVGp")

	-- indent selection
	map("v", "<", "<gv", { desc = "Indent left and reselect" })
	map("v", ">", ">gv", { desc = "Indent right and reselect" })

	--
	-- this typa banner
	--
	map("n", "<space>2", function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local row = cursor[1]
		local line_content = vim.api.nvim_get_current_line()
		local is_blank = line_content:find("^%s*$") ~= nil

		local c_types = { "c", "cpp", "java", "cuda", "javascript", "typescript", "rust", "css" }
		local ft = vim.bo.filetype

		local cursor_col, lines
		if vim.tbl_contains(c_types, ft) then
			lines = { "/*", " * ", "*/" }
			cursor_col = 3
		else
			local cs = vim.bo.commentstring
			local start_part = vim.trim((cs:find("%%s") and cs or "# %s"):match("^(.*)%%s(.*)$"))
			lines = { start_part .. " ", start_part .. " ", start_part .. " " }
			cursor_col = #start_part + 1
		end

		local start_idx = row - 1
		local end_idx = is_blank and row or row - 1
		vim.api.nvim_buf_set_lines(0, start_idx, end_idx, false, lines)

		vim.cmd(string.format("normal! %dG3==", row))

		vim.api.nvim_win_set_cursor(0, { row + 1, cursor_col })
		vim.cmd("startinsert!")
	end, { desc = "ultrabannerator3000" })

	-- [and this one] ------------------------------------------------------------
	vim.api.nvim_create_user_command("Bannerate", function(opts)
		local cs = vim.bo.commentstring:match("^(.*)%%s") or "//"
		cs = vim.trim(cs)
		local width = 79

		for lnum = opts.line1, opts.line2 do
			local line = vim.fn.getline(lnum)
			local indent, text = line:match("^(%s*)(.-)%s*$")

			-- if line already has label use that as src discard everything else
			local existing = text:match("%[(.-)%]")
			if existing then
				text = existing
			else
				local cs_escaped = vim.pesc(cs)
				text = text:gsub("^" .. cs_escaped .. "%s*%-*%s*", "")
				text = text:gsub("%s*%-+%s*$", "") -- strip trailing dashes if any
			end

			local sep = (cs == "--") and "" or " --"
			local prefix = indent .. cs .. sep .. " [" .. text .. "] "
			local banner = prefix .. string.rep("-", math.max(0, width - #prefix))
			vim.fn.setline(lnum, banner)
		end
	end, { range = true, nargs = 0 })

	map({ "x", "n" }, "<leader>g", ":Bannerate<CR>", { silent = true })
	map({ "i" }, "<C-g>", "<esc>:Bannerate<CR>i", { silent = true })

	--
	-- command mode
	--
	map("c", "<C-A>", "<Home>")
	map("c", "<C-B>", "<Left>")
	map("c", "<C-D>", "<Del>")
	map("c", "<C-E>", "<End>")
	map("c", "<C-F>", "<Right>")
	map("c", "<M-f>", "<S-Right>")
	map("c", "<M-b>", "<S-Left>")
	map("c", "<C-K>", [[<C-\>e(" " . getcmdline())[:getcmdpos()-1]<CR>]])

	-- make
	map("n", "<leader>4", "<cmd>make<CR>")
	map("n", "<leader>3", "<cmd>make test<CR>")
end

---------------------------------
---         autocmds          ---
---------------------------------
local autocmd = vim.api.nvim_create_autocmd
do
	autocmd("FileType", {
		pattern = "odin",
		callback = function()
			vim.opt_local.makeprg = "odin run ."
		end,
	})


	autocmd("LspAttach", {
		callback = function(event)
			local lsp_map = function(modes, key, cmd)
				vim.keymap.set(modes, key, cmd, { buffer = event.buf })
			end

			lsp_map("n", "gd", vim.lsp.buf.definition)
			lsp_map("n", "gq", vim.lsp.buf.format)
			lsp_map("n", "K", vim.lsp.buf.hover)
			lsp_map("n", "<C-k>", vim.diagnostic.open_float)
		end,
	})

	autocmd("TextYankPost", {
		desc = "highlight text on yank",
		pattern = "*",
		callback = function()
			vim.highlight.on_yank({
				higroup = "IncSearch",
				timeout = 40,
			})
		end,
	})

	autocmd({ "FileType" }, {
		desc = "keymap 'q' to close help/quickfix/netrw/etc windows",
		pattern = "help,qf,netrw",
		callback = function()
			vim.keymap.set(
				"n",
				"q",
				"<C-w>c",
				{ buffer = true, desc = "Quit (or Close) help, quickfix, netrw, etc windows" }
			)
		end,
	})

	autocmd("BufReadPost", {
		desc = "jump to last pos when opening a file",
		callback = function(args)
			local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line("$")
			local not_commit = vim.b[args.buf].filetype ~= "commit"

			if valid_line and not_commit then
				vim.cmd([[normal! g`"]])
			end
		end,
	})


	autocmd("FileType", {
		pattern = "zig",
		callback = function()
			local function send_keys(keys, mode)
				local replaced = vim.api.nvim_replace_termcodes(keys, true, false, true)
				vim.api.nvim_feedkeys(replaced, mode, false)
			end
			vim.cmd("set colorcolumn=100")
			-- vim.keymap.set({ "v", "n" }, "<leader>r", ":make run<cr>", { buffer = true })
			vim.keymap.set("v", "<leader>2", function()
				send_keys("sa)hi@", "v")
			end, { buffer = true })
			vim.keymap.set("v", "<leader>3", function()
				send_keys("sa)hi@as<Right>, <Left><Left>", "v")
			end, { buffer = true })
		end,
	})
end

-- [plugins] ------------------------------------------------------------------
do
	vim.pack.add({
		-- [mini] -------------------------------------------------------------------
		"https://github.com/stevearc/oil.nvim",
		"https://github.com/nvim-mini/mini.icons",
		"https://github.com/nvim-mini/mini.align",
		"https://github.com/nvim-mini/mini.pairs",
		"https://github.com/nvim-mini/mini.surround",
		"https://github.com/nvim-mini/mini.extra",
		"https://github.com/nvim-mini/mini.pick",
		-- [language] ---------------------------------------------------------------
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/mason-org/mason-lspconfig.nvim",
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
		"https://github.com/MeanderingProgrammer/treesitter-modules.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/lewis6991/gitsigns.nvim",
		"https://github.com/L3MON4D3/LuaSnip",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/nvim-orgmode/orgmode",
		-- [completion] ---------------------------------------------------------------
		{ src = "https://github.com/Saghen/blink.cmp",                version = "^1" },
	})

	require("mini.icons").setup({})
	require("mini.pairs").setup({})
	require("mini.surround").setup({})

	require("mini.align").setup({
		mappings = {
			start = "g$",
			start_with_preview = "gA",
		},
	})

	require("mini.extra").setup({})
	map({ "n", "x" }, "<leader>D", function()
		MiniExtra.pickers.diagnostic({ scope = "all" })
	end)
	map({ "n", "x" }, "<leader>d", function()
		MiniExtra.pickers.diagnostic({ scope = "current" })
	end)

	local MiniPick = require("mini.pick")
	MiniPick.setup()
	map({ "n", "x" }, "<leader><Tab>", "<cmd>Pick buffers<cr>")
	map({ "n", "x" }, "<leader>f", "<cmd>Pick files<cr>")
	map({ "n", "x" }, "<leader>/", "<cmd>Pick grep_live<cr>")
	map({ "n", "x" }, "<leader>?", "<cmd>Pick keymaps<cr>")

	require("oil").setup({
		keymaps = {
			["g?"] = { "actions.show_help", mode = "n" },
			["<CR>"] = "actions.select",
			["<leader>e"] = "actions.close",
			["<C-s>"] = { "actions.select", opts = { vertical = true } },
			["<C-h>"] = { "actions.select", opts = { horizontal = true } },
			["<C-t>"] = { "actions.select", opts = { tab = true } },
			["<C-p>"] = "actions.preview",
			["<C-c>"] = { "actions.close", mode = "n" },
			["q"] = { "actions.close", mode = "n" },
			["<C-l>"] = "actions.refresh",
			["-"] = { "actions.parent", mode = "n" },
			["_"] = { "actions.open_cwd", mode = "n" },
			["`"] = { "actions.cd", mode = "n" },
			["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["gx"] = "actions.open_external",
			["g."] = { "actions.toggle_hidden", mode = "n" },
			["g\\"] = { "actions.toggle_trash", mode = "n" },
		},
		float = { preview_split = "right" },
		preview_win = { update_on_cursor_moved = true },
	})
	map("n", "<leader>e", "<cmd>Oil --float --preview<cr>")

	-- [language] ---------------------------------------------------------------
	require("mason").setup({})
	require("mason-lspconfig").setup({})

	require("nvim-treesitter").setup({})
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("tree-sitter-enable", { clear = true }),
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(args.match)
			if not lang then
				return
			end
			-- parser may not be installed yet
			if not vim.treesitter.language.add(lang) then
				return
			end
			local ok_hl, hl = pcall(vim.treesitter.query.get, lang, "highlights")
			if ok_hl and hl then
				pcall(vim.treesitter.start, args.buf)
			end
			local ok_ind, ind = pcall(vim.treesitter.query.get, lang, "indents")
			if ok_ind and ind then
				vim.opt_local.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
			end
		end,
	})

	require("gitsigns").setup({
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function m(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			m("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end)

			m("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end)

			m("n", "<leader>hs", gitsigns.stage_hunk)
			m("n", "<leader>hr", gitsigns.reset_hunk)

			m("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)

			m("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)

			m("n", "<leader>hS", gitsigns.stage_buffer)
			m("n", "<leader>hR", gitsigns.reset_buffer)
			m("n", "<leader>hp", gitsigns.preview_hunk)
			m("n", "<leader>hi", gitsigns.preview_hunk_inline)

			m("n", "<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end)

			m("n", "<leader>hd", gitsigns.diffthis)

			m("n", "<leader>hD", function()
				gitsigns.diffthis("~")
			end)

			m("n", "<leader>hQ", function()
				gitsigns.setqflist("all")
			end)
			m("n", "<leader>hq", gitsigns.setqflist)

			m("n", "<leader>tb", gitsigns.toggle_current_line_blame)
			m("n", "<leader>tw", gitsigns.toggle_word_diff)

			m({ "o", "x" }, "ih", gitsigns.select_hunk)
		end,
	})

	local ls = require("luasnip")
	ls.setup({ enable_autosnippets = true })
	ls.config.setup({ store_selection_keys = "<Tab>" })
	require("luasnip.loaders.from_vscode").lazy_load()
	map({ "i" }, "<C-l>", function()
		ls.expand()
	end, { silent = true })
	map({ "i", "s" }, "<C-L>", function()
		ls.jump(1)
	end, { silent = true })
	map({ "i", "s" }, "<C-J>", function()
		ls.jump(-1)
	end, { silent = true })

	require("blink.cmp").setup({
		signature = {
			enabled = true,
			window = { show_documentation = false },
		},
		keymap = {
			preset = "default",
			["<C-n>"] = { "show_and_insert", "select_next", "fallback_to_mappings" },
			["<Tab>"] = { "fallback" },
			["<C-j>"] = { "snippet_forward", "fallback" },
			["<C-k>"] = { "snippet_backward", "fallback" },
			["<C-y>"] = { "select_and_accept", "fallback" },
			["<C-e>"] = false,
			["<S-space>"] = {
				function(cmp)
					cmp.show({ providers = { "snippets" } })
				end,
			},
		},
		completion = {
			list = { selection = { preselect = false } },
			documentation = {
				auto_show = true,
				window = { border = "single" },
			},
			menu = {
				auto_show = function()
					return not vim.tbl_contains({ "markdown" }, vim.bo.filetype)
				end,
				draw = {
					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						label = { width = { max = 40 } },
						kind = {
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
					},
				},
			},
		},
		snippets = { preset = "luasnip" },
	})

	require("orgmode").setup({
		org_agenda_files = "~/orgfiles/**/*",
		org_default_notes_file = "~/orgfiles/refile.org",
		mappings = {
			org = {
				org_cycle = { "gt", desc = "cycle fold" },
				org_global_cycle = { "gT", desc = "cycle fold global" },
			},
		},
	})
end

-- [lsp] ----------------------------------------------------------------------
do
	vim.lsp.config("racket-langserver", {
		cmd = { "racket", "-l", "racket-langserver" },
		filetypes = { "racket" },
	})
	vim.lsp.enable("racket-langserver")

	for _, name in ipairs({
		"c3_lsp",
		"clangd",
		"gopls",
		"jdtls",
		"biome",
		"ts_ls",
		"rust_analyzer",
		"org"
	}) do vim.lsp.enable(name) end

	for name, conf in pairs({
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = {
							vim.api.nvim_get_runtime_file("", true),
							"${3rd}/love2d/library",
						},
					},
					telemetry = { enable = false },
				},
			},
		},
		zls = {
			settings = { zls = { enable_build_on_save = true } },
		},
		ols = {
			init_options = { enable_fake_methods = true },
		},
	}) do
		vim.lsp.config(name, conf)
		vim.lsp.enable(name)
	end
end


-- [runners] ------------------------------------------------------------------
do
	---@param cmd string
	---@param opts? { floating?: boolean, gap?: integer } gap is in cells, applied on all sides
	local function new_runner(cmd, opts)
		opts = opts or {}
		local gap = opts.gap or 2

		return function()
			local buf = vim.api.nvim_create_buf(false, true)

			-- buf already exists at this point, so just set the keymap
			-- directly instead of stacking a new global TermOpen
			-- autocmd every time the runner is invoked
			vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buf })

			local width, height, row, col
			if opts.floating then
				width = vim.o.columns - (gap * 2)
				height = vim.o.lines - (gap * 2) - vim.o.cmdheight
				row = gap
				col = gap
			else
				width = vim.o.columns
				height = vim.o.lines
				row = 0
				col = 0
			end

			local win = vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				row = row,
				col = col,
				width = width,
				height = height,
				style = "minimal",
				-- border = opts.floating and "rounded" or "none",
				border = "none",
				-- title = cmd,
			})

			-- vim likes to color it with your theme
			-- reset it
			vim.api.nvim_set_hl(0, "TerminalReset", {
				bg = "#000000",
				fg = "#ffffff",
				ctermbg = 0,
				ctermfg = 7,
			})

			vim.wo[win].winhighlight = "Normal:TerminalReset,NormalFloat:TerminalReset,EndOfBuffer:TerminalReset"
			vim.bo[buf].syntax = "off"
			vim.bo[buf].filetype = "terminal"

			vim.fn.jobstart(cmd, {
				term = true,
				on_exit = function()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
					if vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end,
			})

			vim.cmd("startinsert")
		end
	end

	local lazygit = new_runner("lazygit", { floating = true })
	vim.api.nvim_create_user_command("LazyGit", lazygit, {})
	map({ "n", "x" }, "<leader>l", lazygit)

	local scooter = new_runner("scooter", { floating = true })
	vim.api.nvim_create_user_command("Scooter", scooter, {})
	map({ "n", "x" }, "<leader>s", scooter)

	-- vim.lsp.inlay_hint.enable()
end

-- [imports] ------------------------------------------------------------------
require("statusline").setup()
require("livegrep")

local runner = require("runner")

vim.keymap.set({ "n", "x" }, "<leader>r", runner.run, {
	buffer = true,
	silent = true,
	desc = "run buffer via registered runner",
})

-- [revo] ---------------------------------------------------------------------
do
	vim.filetype.add({
		extension = {
			rv = "revo",
			revo = "revo",
		},
	})

	vim.pack.add({
		{ src = "https://github.com/romus204/tree-sitter-manager.nvim" },
	})
	vim.treesitter.language.register("revo", "revo")
	require("tree-sitter-manager").setup({
		parser_dir = vim.fn.stdpath("data") .. "/site/parser",
		query_dir = vim.fn.stdpath("data") .. "/site/queries",
		auto_install = true,
		highlight = true,
		languages = {
			revo = {
				install_info = {
					url = "https://codeberg.org/doomy/tree-sitter-revo",
					queries = "queries/",
				},
			},
		},
		nerdfont = true,
		border = "rounded",
		min_width = 78,
		min_height = 40,
	})

	-- lsp
	vim.lsp.config("revo", {
		cmd = { "revo", "lsp" },
		filetypes = { "revo" },
		root_markers = { "lib.json", "exe.json", ".git" },
	})
	vim.lsp.enable("revo")
end
