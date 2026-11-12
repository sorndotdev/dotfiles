local languages = { 'python', 'lua', 'toml', 'yaml', 'json', 'bash', 'markdown', 'markdown_inline' }

local function select(capture)
    return function()
        require('nvim-treesitter-textobjects.select').select_textobject(capture, 'textobjects')
    end
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').install(languages)
            vim.api.nvim_create_autocmd('FileType', {
                pattern = languages,
                callback = function() pcall(vim.treesitter.start) end,
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        lazy = false,
        opts = { select = { lookahead = true } },
        keys = {
            { 'af', select('@function.outer'), mode = { 'x', 'o' }, desc = 'a function' },
            { 'if', select('@function.inner'), mode = { 'x', 'o' }, desc = 'inner function' },
            { 'ac', select('@class.outer'), mode = { 'x', 'o' }, desc = 'a class' },
            { 'ic', select('@class.inner'), mode = { 'x', 'o' }, desc = 'inner class' },
        },
    },
    -- Pin the enclosing class/def lines at the top while scrolling.
    { 'nvim-treesitter/nvim-treesitter-context', event = 'BufReadPost', opts = { max_lines = 3 } },
}
