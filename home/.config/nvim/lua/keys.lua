vim.keymap.set('n', '<Esc>', ':w<CR>', { desc = 'Save' })
vim.keymap.set('n', '<C-a>', 'ggVg', { desc = 'Select All' })

for _, mode in ipairs({ 'i', 'n', 'c' }) do
  vim.keymap.set(mode, '<A-Left>', '<S-Left>')
  vim.keymap.set(mode, '<A-Right>', '<S-Right>')
end

vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true, desc = 'Next completion' })
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Previous completion' })
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true, desc = 'Accept completion' })
