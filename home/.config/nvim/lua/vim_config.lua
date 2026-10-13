local o = vim.opt

vim.g.mapleader = ' '

o.expandtab = true
o.shiftwidth = 4
o.number = true
o.relativenumber = true
o.ignorecase = true
o.smartcase = true
o.clipboard = 'unnamedplus'
o.completeopt = 'menuone,noinsert,fuzzy'
o.scrolloff = 16
o.undofile = true

vim.opt.termguicolors = true

vim.o.background = 'light'
vim.cmd([[
    highlight Normal guifg=NONE guibg=NONE
    highlight NormalNC guibg=NONE
    highlight NormalFloat guibg=NONE
    highlight SignColumn guibg=NONE
    highlight EndOfBuffer guibg=NONE
]])

vim.o.guicursor = table.concat({
    "n-c-sm:block-Cursor-blinkwait600-blinkon1100-blinkoff900",
    "i-ci-ve:ver35-CursorInsert",
    "v:hor20-CursorVisual",
    "r-cr-o:block-CursorReplace",
}, ",")

vim.o.laststatus = 3
vim.o.showmode = false
vim.o.winborder = "single"
vim.o.statusline = "%!v:lua.require'statusline'.render()"
