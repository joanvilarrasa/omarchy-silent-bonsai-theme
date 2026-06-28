-- --------------------------------------------------------------------------------------
-- [[ OPTIONS ]]
-- --------------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.tabstop = 2
vim.o.wrap = false
vim.o.swapfile = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.showmode = false
vim.o.updatetime = 250 -- Default is 4000 (ms). This is how long vim wayts to acto on the swapfile and to trigger the 'CursorHold' event.
vim.o.timeoutlen = 300 -- Default is 1000 (ms). Time that vim waits for a sequence to complete.
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = 'split'
vim.o.winborder = 'rounded'
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- --------------------------------------------------------------------------------------
-- [[ PLUGINS ]]
-- --------------------------------------------------------------------------------------
vim.loader.enable() -- Enable faster startup by caching compiled Lua modules
vim.pack.add({
	{ src = 'https://github.com/stevearc/oil.nvim' },
	{ src = 'https://github.com/folke/which-key.nvim' },
	{ src = 'https://github.com/saghen/blink.cmp',                        version = vim.version.range '1.*' },
	{ src = 'https://github.com/nvim-mini/mini.surround' },
	{ src = 'https://github.com/jake-stewart/multicursor.nvim' },
	{ src = 'https://github.com/nvim-mini/mini.statusline' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
	{ src = 'https://github.com/esmuellert/codediff.nvim' },
	{ src = 'https://github.com/dzfrias/arena.nvim' },
	{ src = 'https://github.com/NeogitOrg/neogit' },
	{ src = 'https://codeberg.org/ziglang/zig.vim' },
})

require('mini.surround').setup()
require('multicursor-nvim').setup()
require('oil').setup()

local telescope_actions = require "telescope.actions"
require('telescope').setup {
	pickers = {
		buffers = {
			initial_mode = "normal",
			mappings = {
				n = {
					["<c-d>"] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
				}
			},
		},
	},
	extensions = {
		['ui-select'] = { require('telescope.themes').get_dropdown() },
	},
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

require('arena').setup({
	max_items = 10,
	keybinds = {
		["v"] = function(win)
			local current = win:current()
			local info = vim.fn.getbufinfo(current.bufnr)[1]
			vim.cmd({
				cmd = "split",
				args = { vim.fn.bufname(current.bufnr) },
				mods = { vertical = true },
			})
			vim.fn.cursor(info.lnum, 0)
		end,
	}
})

require('which-key').setup {
	delay = 0,
	spec = {
		{ '<leader>l', group = '[L]SP Actions', mode = { 'n' } },
		{ '<leader>o', group = '[O]pen',        mode = { 'n' } },
		{ '<leader>s', group = '[S]earch',      mode = { 'n', 'v' } },
	},
}
require('blink.cmp').setup({
	keymap = {
		preset = 'default',
		['<CR>'] = { 'accept', 'fallback' }
	},
	appearance = { nerd_font_variant = 'mono' },
	completion = {
		accept = {
			dot_repeat = false,
		},
		documentation = {
			auto_show = false,
		},
		list = {
			max_items = 10,
			selection = { preselect = true, auto_insert = false }
		},
		trigger = {
			show_on_backspace = true,
		}
	},
	sources = {
		default = { 'lsp', 'path' },
	},
	fuzzy = { implementation = 'lua' },
	signature = { enabled = true },
})

require('neogit').setup()
require('mini.statusline').setup({
	content = {
		active = function()
			local stl           = require('mini.statusline')
			local mode, mode_hl = stl.section_mode({ trunc_width = 120 })
			local diagnostics   = stl.section_diagnostics({ trunc_width = 75 })
			-- local lsp           = stl.section_lsp({ trunc_width = 75 })
			local filename      = stl.section_filename({ trunc_width = 140 })
			local fileinfo      = stl.section_fileinfo({ trunc_width = 9999 }) -- Show only the file type
			local location      = stl.section_location({ trunc_width = 9999 }) -- Show only the current cursor position
			local search        = stl.section_searchcount({ trunc_width = 75 })

			return stl.combine_groups({
				{ hl = mode_hl,                 strings = { mode } },
				-- { hl = 'MiniStatuslineDevinfo', strings = { diagnostics, lsp } },
				{ hl = 'MiniStatuslineDevinfo', strings = { diagnostics } },
				'%<', -- Mark general truncate point
				{ hl = 'MiniStatuslineFilename', strings = { filename } },
				'%=', -- End left alignment
				{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
				{ hl = mode_hl,                  strings = { search, location } },
			})
		end,
	}
})

-- --------------------------------------------------------------------------------------
-- [[ KEYMAPS AND CONFIG ]]
-- --------------------------------------------------------------------------------------

-- Native
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Cancel search with Esc
vim.keymap.set('n', '<A-j>', ":m .+1<CR>==")        -- Move up (Normal mode)
vim.keymap.set('n', '<A-k>', ":m .-2<CR>==")        -- Move down (Normal mode)
vim.keymap.set('x', '<A-j>', ":m '>+1<CR>gv=gv")    -- Move up (Select mode)
vim.keymap.set('x', '<A-k>', ":m '<-2<CR>gv=gv")    -- Move down (Select mode)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })


-- Arena
vim.keymap.set('n', '<leader>a', function() require('arena').toggle() end, { desc = "Arena" })

-- Oil
vim.keymap.set('n', '<leader>f', ":Oil<CR>", { desc = '[F]ile Explorer' })

-- Neogit
vim.keymap.set('n', '<leader>g', '<cmd>Neogit<CR>', { desc = '[G]it' })

-- Telescope
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch Existing [B]uffers' }) -- Override default behavior and theme when searching
-- vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/',
	function()
		builtin.live_grep {
			grep_open_files = true, prompt_title = 'Live Grep in Open Files'
		}
	end,
	{ desc = '[S]earch [/] in Open Files' }
)

-- Muticursor
local mc = require 'multicursor-nvim'
vim.keymap.set("n", "<up>", function() mc.lineAddCursor(-1) end)
vim.keymap.set("n", "<down>", function() mc.lineAddCursor(1) end)
vim.keymap.set("n", "<leader><up>", function() mc.lineSkipCursor(-1) end, { desc = 'Skip Cursor Up' })
vim.keymap.set("n", "<leader><down>", function() mc.lineSkipCursor(1) end, { desc = 'Skip Cursor Down' })
vim.keymap.set("x", "<up>", function() mc.matchAddCursor(-1) end)
vim.keymap.set("x", "<down>", function() mc.matchAddCursor(1) end)
vim.keymap.set("x", "<leader><up>", function() mc.matchSkipCursor(-1) end, { desc = 'Skip Match Up' })
vim.keymap.set("x", "<leader><down>", function() mc.matchSkipCursor(1) end, { desc = 'Skip Match Down' })
vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)
vim.keymap.set("n", "<c-leftrelease>", mc.handleMouseRelease)
mc.addKeymapLayer(function(layerSet)
	layerSet("n", "<esc>", function() mc.clearCursors() end)
end)

-- Diagnostics
vim.diagnostic.config {
	update_in_insert = false,
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	-- Can switch between these as you prefer
	virtual_text = false, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float {
				bufnr = bufnr,
				scope = 'cursor',
				focus = false,
			}
		end,
	},
}
vim.keymap.set('n', '<leader>od', vim.diagnostic.setloclist, { desc = '[D]iagnostics' })
-- --------------------------------------------------------------------------------------
-- [[ AUTOCOMMANDS ]]
-- --------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
	callback = function(event)
		local buf = event.buf
		vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
		vim.keymap.set('n', '<leader>li', builtin.lsp_implementations,
			{ buffer = buf, desc = '[G]oto [I]mplementation' })
		vim.keymap.set('n', '<leader>ld', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
		vim.keymap.set('n', '<leader>lc', vim.diagnostic.open_float,
			{ buffer = buf, desc = '[C]ursor Diagnostics' })
		vim.keymap.set('n', '<leader>lt', builtin.lsp_type_definitions,
			{ buffer = buf, desc = '[G]oto [T]ype Definition' })
		vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = '[F]ormat Document' })
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover)
	end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function() vim.hl.on_yank() end,
})

-- --------------------------------------------------------------------------------------
-- [[ LSP ]]
-- --------------------------------------------------------------------------------------
-- ZIG
vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0
vim.lsp.config['zls'] = {
	cmd = { 'zls' },
	filetypes = { 'zig' },
	root_markers = { 'build.zig' },
	settings = {
		zls = {
			enable_snippets = false,
			enable_build_on_save = true,
		}
	}
}

-- GO
vim.lsp.config['gopls'] = {}
-- Biome
vim.lsp.config['biome'] = {}

-- Lua
vim.lsp.config['lua_ls'] = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = {
		'.emmyrc.json',
		'.luarc.json',
		'.luarc.jsonc',
		'.luacheckrc',
		'.stylua.toml',
		'stylua.toml',
		'selene.toml',
		'selene.yml',
		'.git',
	},
	settings = {
		Lua = {
			codeLens = { enable = true },
			hint = { enable = true, semicolon = 'Disable' },
		},
	},

	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
			    path ~= vim.fn.stdpath('config')
			    and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
			then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				version = 'LuaJIT',
				path = {
					'lua/?.lua',
					'lua/?/init.lua',
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
				},
			},
		})
	end
}

-- Enable or disable languages
vim.lsp.enable({ "lua_ls", "zls", "gopls", "biome" })

-- --------------------------------------------------------------------------------------
-- [[ COLORSCHEME ]]
-- --------------------------------------------------------------------------------------
local silent_bonsai = require 'colors.silentbonsai'
silent_bonsai.setup {
	transparent = false, -- enable transparent background
	terminal_colors = true, -- set terminal colors
	dim_inactive = false, -- dim inactive windows
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = 'dark', -- "dark", "transparent", or "normal"
		floats = 'dark', -- "dark", "transparent", or "normal"
	},
}
silent_bonsai.load()
