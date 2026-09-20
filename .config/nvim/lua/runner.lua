--- the any filetype runner!
---
--- sometimes, you might want to override it
--- your `sh` files may not be bash
--- , or your js interpreter might not be node
local M = {}

M.runners = {}

--- register a runner for a filetype
---
--- config = {
---   cmd   = { "revo", "-D" }  -- or a `fn(bufnr) -> table`
---   name  = "revo"            -- what i show in the window title (defaults to filetype)
---   stdin = true              -- whether to pipe source into the process
---   env   = nil                -- extra env vars
--- }
function M.register(ft, config)
	assert(type(config.cmd) == "table" or type(config.cmd) == "function",
		"runner.register: config.cmd must be a table or function")

	M.runners[ft] = vim.tbl_extend("force", {
		name = ft,
		output_filetype = ft .. "-output",
		stdin = true,
	}, config)
end

local function show_output(config, stdout, stderr, exit_code)
	local output = {}

	for _, l in ipairs(stdout) do
		if l ~= "" then table.insert(output, l) end
	end

	for _, l in ipairs(stderr) do
		if l ~= "" then table.insert(output, l) end
	end

	if #output == 0 then
		output = { "*no output*" }
	end

	table.insert(output, "")

	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = config.output_filetype

	local width = 20

	for _, line in ipairs(output) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end

	width = math.min(width + 2, math.floor(vim.o.columns * 0.8))

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = math.min(#output, 12),
		style = "minimal",
		border = "rounded",
		title = exit_code == 0 and (" " .. config.name .. " ") or (" " .. config.name .. " error "),
		title_pos = "center",
	})

	vim.wo[win].wrap = false
	vim.api.nvim_win_set_cursor(win, { #output, 0 })

	local close = function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	vim.keymap.set("n", "q", close, { buffer = buf, silent = true, nowait = true })
	vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true, nowait = true })
end

--- run a runner for the current buffer's filetype if it's registered
--- if not, returns false
function M.run()
	local ft = vim.bo.filetype
	local config = M.runners[ft]

	if not config then
		vim.notify("runner: no runner registered for filetype '" .. ft .. "'", vim.log.levels.ERROR)
		return false
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local cmd = config.cmd

	if type(cmd) == "function" then
		cmd = cmd(bufnr)
	end

	local stdout, stderr = {}, {}

	local job_id = vim.fn.jobstart(cmd, {
		stdin = config.stdin and "pipe" or nil,
		env = config.env,
		stdout_buffered = true,
		stderr_buffered = true,

		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,

		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,

		on_exit = function(_, exit_code)
			vim.schedule(function()
				show_output(config, stdout, stderr, exit_code)
			end)
		end,
	})

	if job_id <= 0 then
		vim.notify("runner: failed to start " .. tostring(type(cmd) == "table" and cmd[1] or cmd), vim.log.levels.ERROR)
		return false
	end

	if config.stdin then
		local source = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
		vim.fn.chansend(job_id, source)
		vim.fn.chanclose(job_id, "stdin")
	end
end

---------------------
-- default runners --
---------------------

--- check it out it's pretty cool that's my language https://revo.lung.fyi
M.register("revo", { cmd = { "revo", "-D" }, name = "revo" })
M.register("sh", { cmd = { "bash" }, name = "bash" })
--- should be just ok?
M.register("go", {
	cmd = function(bufnr) return { "go", "run", vim.api.nvim_buf_get_name(bufnr) } end,
	name = "go",
	stdin = false,
})

--
-- lisps deserve icecream
--

--- reads forms off stdin asis
M.register("fennel", { cmd = { "fennel" }, name = "fennel" })
--- guile takes a script off stdin with -s -
M.register("scheme", { cmd = { "guile", "-s", "-" }, name = "guile" })
--- sbcl needs --script - to read from stdin instead of a real file
M.register("lisp", { cmd = { "sbcl", "--script", "-" }, name = "sbcl" })
--- racket also happily takes a script over stdin
M.register("racket", { cmd = { "racket", "-f", "-" }, name = "racket" })
--- clojure's slow to boot but probably alright, -M -e can't take stdin so this one's file-based
M.register("clojure", {
	cmd = function(bufnr) return { "clojure", "-M", vim.api.nvim_buf_get_name(bufnr) } end,
	name = "clojure",
	stdin = false,
})


-------------------------
-- tricky runner impls --
-------------------------

--- no im not using nvim's
---
--- tries src as expr first (so `2 + 2` => `4`, i know stock repl does the same thing)
--- falls back to running it like normal if that doesn't work
M.register("lua", {
	cmd = {
		"lua", "-e",
		[[
			local src = io.read("*a")
			local chunk, err = load("return " .. src)
			if not chunk then
				chunk, err = load(src)
			end
			if not chunk then
				io.stderr:write(err, "\n")
				os.exit(1)
			end
			local results = { chunk() }
			for _, v in ipairs(results) do
				print(tostring(v))
			end
		]],
	},
	name = "lua",
})

-- its basically the same thing as lua above
M.register("python", {
	cmd = {
		"python3", "-c",
		[[
import sys, ast

src = sys.stdin.read()

try:
	tree = ast.parse(src, mode="eval")
	result = eval(compile(tree, "<runner>", "eval"))
	if result is not None:
		print(repr(result))
except SyntaxError:
	exec(compile(src, "<runner>", "exec"))
	]],
	},
	name = "python",
})

-- and this is the same as both of them above
M.register("javascript", {
	cmd = {
		"node", "-e",
		[[
			const fs = require("fs");
			const util = require("util");

			const src = fs.readFileSync(0, "utf8");

			let result;
			try {
				result = eval("(" + src + ")");
			} catch (e) {
				if (e instanceof SyntaxError) {
					result = eval(src);
				} else {
					throw e;
				}
			}

			if (result !== undefined) {
				console.log(typeof result === "string" ? result : util.inspect(result));
			}
		]],
	},
	name = "node",
})

return M
