-- save by pressing Escape
vim.keymap.set('n', '<Esc>', ':w<CR>', { desc = 'Save' })

-- select all
vim.keymap.set('n', '<C-a>', 'ggVg', { desc = 'Select All' })

-- option+arrows jump words like shift+arrows (nvim built-ins handle <S-Left>/<S-Right>)
for _, mode in ipairs({ 'i', 'n', 'c' }) do
  vim.keymap.set(mode, '<A-Left>', '<S-Left>')
  vim.keymap.set(mode, '<A-Right>', '<S-Right>')
end

-- pasting over a selection doesn't clobber clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
