-- save by pressing Escape
vim.keymap.set('n', '<Esc>', ':w<CR>', { desc = 'Save' })

-- select all
vim.keymap.set('n', '<C-a>', 'ggVg', { desc = 'Select All' })

-- pasting over a selection doesn't clobber clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
