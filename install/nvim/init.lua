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
vim.o.winborder = "rounded"
vim.o.pumborder = 'rounded'
vim.o.autocomplete = true
vim.o.pumheight = 5
vim.opt.complete:append('o')
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- --------------------------------------------------------------------------------------
-- [[ PLUGINS ]]
-- --------------------------------------------------------------------------------------
vim.pack.add({
	{ src = 'https://github.com/stevearc/oil.nvim' },
	{ src = 'https://github.com/folke/which-key.nvim' },
	{ src = 'https://github.com/nvim-mini/mini.surround' },
	{ src = 'https://github.com/jake-stewart/multicursor.nvim' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
	{ src = 'https://codeberg.org/ziglang/zig.vim' },
})

require('mini.surround').setup()
require('multicursor-nvim').setup()
require('oil').setup {}

require('telescope').setup {
	extensions = {
		['ui-select'] = { require('telescope.themes').get_dropdown() },
	},
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

require('which-key').setup {
	delay = 0,
	spec = {
		{ 'gr', group = 'LSP Actions', mode = { 'n' } },
	},
}

-- --------------------------------------------------------------------------------------
-- [[ KEYMAPS AND CONFIG ]]
-- --------------------------------------------------------------------------------------

-- Native
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Cancel search with Esc
vim.keymap.set('n', '<A-j>', ":m .+1<CR>==") -- Move up (Normal mode)
vim.keymap.set('n', '<A-k>', ":m .-2<CR>==") -- Move down (Normal mode)
vim.keymap.set('x', '<A-j>', ":m '>+1<CR>gv=gv") -- Move up (Select mode)
vim.keymap.set('x', '<A-k>', ":m '<-2<CR>gv=gv") -- Move down (Select mode)
vim.keymap.set('i', '<Tab>', 'pumvisible() ? "<C-n><C-y>" : "<Tab>"', { expr = true, silent = true }) -- Select first completion with tab

-- Oil
vim.keymap.set('n', '<leader>e', ":Oil<CR>")

-- Telescope
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' }) -- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
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
vim.keymap.set("n", "<leader><up>", function() mc.lineSkipCursor(-1) end)
vim.keymap.set("n", "<leader><down>", function() mc.lineSkipCursor(1) end)
vim.keymap.set("x", "<up>", function() mc.matchAddCursor(-1) end)
vim.keymap.set("x", "<down>", function() mc.matchAddCursor(1) end)
vim.keymap.set("x", "<leader><up>", function() mc.matchSkipCursor(-1) end)
vim.keymap.set("x", "<leader><down>", function() mc.matchSkipCursor(1) end)
vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)
vim.keymap.set("n", "<c-leftrelease>", mc.handleMouseRelease)
mc.addKeymapLayer(function(layerSet)
	layerSet("n", "<esc>", function() mc.clearCursors() end)
end)

-- --------------------------------------------------------------------------------------
-- [[ AUTOCOMMANDS ]]
-- --------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
	callback = function(event)
		local buf = event.buf
		vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
		vim.keymap.set('n', 'gri', builtin.lsp_implementations,
			{ buffer = buf, desc = '[G]oto [I]mplementation' })
		vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
		vim.keymap.set('n', 'grc', vim.diagnostic.open_float,
			{ buffer = buf, desc = '[G]oto [C]ursor Diagnostics' })
		vim.keymap.set('n', 'grt', builtin.lsp_type_definitions,
			{ buffer = buf, desc = '[G]oto [T]ype Definition' })
		vim.keymap.set('n', 'grf', vim.lsp.buf.format, { desc = '[F]ormat Document' })
		vim.keymap.del('n', 'grx')
		vim.keymap.del('n', 'gra')
		vim.keymap.del('n', 'grn')
		vim.keymap.del('n', 'gO')
	end,
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
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
