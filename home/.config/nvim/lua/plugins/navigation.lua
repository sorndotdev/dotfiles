return {
    {
        'stevearc/oil.nvim',
        opts = { view_options = { show_hidden = true } },
        keys = { { '-', '<cmd>Oil<cr>', desc = 'File Browser (parent dir)' } },
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        opts = {
            picker = {
                enabled = true,
                sources = {
                    explorer = { hidden = true },
                },
            },
            explorer = { enabled = true },
            terminal = { enabled = true },
            notifier = { enabled = true },
            input = { enabled = true },
            image = { enabled = true },
        },
        keys = {
            { '<leader>e', function() Snacks.explorer() end, desc = 'File Tree' },
            { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Search Everywhere' },
            { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
            { '<leader>s', function() Snacks.picker.grep() end, desc = 'Search Text' },
            { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
            { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
            { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'Find Usages' },
            { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
            { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto Type Definition' },
            { '<leader>o', function() Snacks.picker.lsp_symbols() end, desc = 'File Outline' },
            { '<leader>O', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Project Symbols' },
            { '<leader>x', function() Snacks.picker.diagnostics() end, desc = 'Problems' },
            { '<C-/>', function() Snacks.terminal.toggle() end, mode = { 'n', 't' }, desc = 'Terminal' },
            { '<C-_>', function() Snacks.terminal.toggle() end, mode = { 'n', 't' }, desc = 'which_key_ignore' },
        },
    },
}
