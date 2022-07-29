require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'junegunn/seoul256.vim'

    use 'machakann/vim-sandwich'

    use 'ojroques/vim-oscyank'

    use 'tpope/vim-fugitive'

    use 'romainl/vim-cool'

    use 'nvim-lualine/lualine.nvim'

    use 'tversteeg/registers.nvim'

    use 'jiangmiao/auto-pairs'

    use 'lewis6991/gitsigns.nvim' 

    use {
	'nvim-telescope/telescope.nvim', tag = '0.1.0',
	requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {
	{ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }, 
	{ 'nvim-treesitter/nvim-treesitter-textobjects' },
	{ 'nvim-treesitter/nvim-treesitter-context',
	    config = function()
		require('treesitter-context').setup{
		    enable = true,
		}
	    end
	},
    }

    use { 'neovim/nvim-lspconfig', 
	requires = {'williamboman/nvim-lsp-installer', 
	    config = function()
		require('nvim-lsp-installer').setup{}
	    end
	}
    }

end)

-- status line
require('lualine').setup {
    options = {
	theme = 'seoul256',
	icons_enabled = false,
	component_separators = { left = '', right = '|' },
	section_separators = { left = '', right = '' }
    },
    sections = {
	lualine_b = {'branch', 'diff', 'diagnostics'},
	lualine_x = {'encoding'},
	lualine_y = {'progress'},
	lualine_z = {'filetype'}
    }
}

-- treesitter
require'nvim-treesitter.configs'.setup {
    auto_install = true,
    highlight = {
	enable = true,
	additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
	enable = true,
	keymaps = {
	    init_selection = 'gnn',
	    scope_incremental = '<CR>',
	    node_incremental = '<TAB>',
	    node_decremental = '<S-TAB>',
	},
    },
    indent = {
	enable = true
    },
    textobjects = {
	select = {
	    enable = true,

	    -- Automatically jump forward to textobj, similar to targets.vim
	    lookahead = true,

	    keymaps = {
		-- You can use the capture groups defined in textobjects.scm
		["af"] = "@function.outer",
		["if"] = "@function.inner",
		["ac"] = "@class.outer",
		["ic"] = "@class.inner",
	    },
	},
    },
}

-- nvim-lspconfig
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'

  -- Mappings.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local nvim_lsp = require('lspconfig')

local servers = { 'gopls', 'bashls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
  }
end

-- telescope
vim.keymap.set('n', '<C-P>', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope grep_string<cr>')
vim.keymap.set('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>')

-- gitsigns
require('gitsigns').setup{
    current_line_blame_opts = {
	delay = 300
    },
    on_attach = function(bufnr)
	local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- colorscheme
vim.g.seoul256_background = 233
vim.cmd('colorscheme seoul256')

-- setting clipboard provider
local function copy(lines, _)
  vim.fn.OSCYankString(table.concat(lines, "\n"))
end

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype('')
  }
end

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = copy,
    ["*"] = copy
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste
  }
}

-- settings
vim.cmd [[autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | OSCYankReg " | endif]]
vim.cmd([[ au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 700 } ]])
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- fast saving
vim.keymap.set('n', '<leader>s', ':w<CR>')
-- reload config
vim.keymap.set('n', '<leader>r', ':so %<CR>')
vim.keymap.set('n', ',,', ':tabnew<CR>')
vim.keymap.set('n', ',.', ':tabnext<CR>')
vim.keymap.set('n', '.,', ':tabprev<CR>')
vim.keymap.set('n', '<Space>', '<PageDown>')

vim.opt.ignorecase = true
vim.opt.mouse = 'a'
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
