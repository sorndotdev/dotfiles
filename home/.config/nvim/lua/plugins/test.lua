local function neotest() return require('neotest') end

return {
    {
        'nvim-neotest/neotest',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'nvim-neotest/neotest-python',
        },
        config = function()
            require('neotest').setup({
                adapters = {
                    require('neotest-python')({ runner = 'pytest' }),
                },
            })
        end,
        keys = {
            { '<leader>tt', function() neotest().run.run() end, desc = 'Test Nearest' },
            { '<leader>tf', function() neotest().run.run(vim.fn.expand('%')) end, desc = 'Test File' },
            { '<leader>ta', function() neotest().run.run(vim.fn.getcwd()) end, desc = 'Test All' },
            { '<leader>tl', function() neotest().run.run_last() end, desc = 'Test Last' },
            { '<leader>ts', function() neotest().summary.toggle() end, desc = 'Test Summary' },
            { '<leader>to', function() neotest().output.open({ enter = true }) end, desc = 'Test Output' },
            { ']t', function() neotest().jump.next({ status = 'failed' }) end, desc = 'Next Failed Test' },
            { '[t', function() neotest().jump.prev({ status = 'failed' }) end, desc = 'Prev Failed Test' },
        },
    },
}
