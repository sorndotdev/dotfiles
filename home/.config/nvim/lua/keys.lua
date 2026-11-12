-- Files and Oil (acwrite: saving applies its changes). The tree, test panels
-- and terminals can't be written.
vim.keymap.set('n', '<Esc>', function()
  if vim.bo.buftype == '' or vim.bo.buftype == 'acwrite' then vim.cmd('write') end
end, { desc = 'Save' })
vim.keymap.set('n', '<C-a>', 'ggVg', { desc = 'Select All' })

for _, mode in ipairs({ 'i', 'n', 'c' }) do
  vim.keymap.set(mode, '<A-Left>', '<S-Left>')
  vim.keymap.set(mode, '<A-Right>', '<S-Right>')
end

vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- nvim's built-in gr* LSP maps would make `gr` (Find Usages) wait for a second key.
for _, lhs in ipairs({ 'grr', 'grn', 'gra', 'gri', 'grt', 'grx' }) do
  for _, mode in ipairs({ 'n', 'x' }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

-- Cmd-[ / Cmd-] go back / forward, like IntelliJ. WezTerm sends them as
-- <D-[> / <D-]>, but only to a pane whose `in_nvim` user var is set.
vim.keymap.set('n', '<D-[>', '<C-o>', { desc = 'Back' })
vim.keymap.set('n', '<D-]>', '<C-i>', { desc = 'Forward' })

local function set_in_nvim(value)
  vim.api.nvim_ui_send(('\027]1337;SetUserVar=in_nvim=%s\007'):format(vim.base64.encode(value)))
end
vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResume' }, { callback = function() set_in_nvim('1') end })
vim.api.nvim_create_autocmd({ 'VimLeavePre', 'VimSuspend' }, { callback = function() set_in_nvim('') end })

-- :qq quits all, as :q quits one window.
vim.cmd([[cnoreabbrev <expr> qq getcmdtype() == ':' && getcmdline() ==# 'qq' ? 'qa' : 'qq']])
