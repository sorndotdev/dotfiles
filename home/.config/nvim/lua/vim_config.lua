local o = vim.opt

vim.g.mapleader = ' '       -- space is the leader key

o.expandtab = true          -- spaces, not tabs
o.shiftwidth = 4            -- 4 spaces per indent level
o.number = true             -- absolute number on the cursor line, relative elsewhere
o.relativenumber = true     -- relative line numbers for fast jumps
o.ignorecase = true         -- search is case-insenstitive by default
o.smartcase = true          -- case-sensitive only if typing a capital letter
o.clipboard = 'unnamedplus' -- share the system clipboard
o.scrolloff = 16            -- keep cursor away from the screen edge
o.undofile = true           -- persistent undo across sessions

vim.opt.termguicolors = true

vim.api.nvim_set_hl(0, "Normal", {
  bg = "NONE",
})

vim.api.nvim_set_hl(0, "NormalNC", {
  bg = "NONE",
})

vim.api.nvim_set_hl(0, "SignColumn", {
  bg = "NONE",
})

vim.api.nvim_set_hl(0, "EndOfBuffer", {
  bg = "NONE",
})
