-- basedpyright for types and navigation, ruff for lint, imports and format.
-- Mason installs both; mason-lspconfig enables them with nvim-lspconfig's
-- defaults plus the overrides below.

-- In a uv workspace the .venv and uv.lock sit at the workspace root, above
-- each member's pyproject.toml. Root both servers there, so they see the
-- workspace's venv and ruff config, and one server covers every member.
local function root_dir(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { 'uv.lock', '.venv' })
        or vim.fs.root(bufnr, { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' }))
end

local function venv_bin(root, name)
    local path = root and root .. '/.venv/bin/' .. name
    return path and vim.fn.executable(path) == 1 and path or nil
end

vim.lsp.config('basedpyright', {
    root_dir = root_dir,
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            analysis = { typeCheckingMode = 'standard' },
        },
    },
    -- Use the project's uv venv, so imports resolve without activating it.
    before_init = function(_, config)
        local python = venv_bin(config.root_dir, 'python')
        if python then
            config.settings.python = vim.tbl_extend('force', config.settings.python or {}, { pythonPath = python })
        end
    end,
})

-- The project's own ruff when it has one: a newer ruff adds preview rules the
-- project's CI doesn't run.
vim.lsp.config('ruff', {
    root_dir = root_dir,
    cmd = function(dispatchers, config)
        local ruff = venv_bin(config.root_dir, 'ruff') or 'ruff'
        return vim.lsp.rpc.start({ ruff, 'server' }, dispatchers, { cwd = config.root_dir })
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'ruff' then
            -- Hover comes from basedpyright.
            client.server_capabilities.hoverProvider = false
        end
    end,
})

-- Sort imports, then format, both through ruff and both before returning, so
-- the format runs on the sorted text.
local function organize_imports(client)
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { 'source.organizeImports.ruff' }, diagnostics = {} }
    local res = client:request_sync('textDocument/codeAction', params, 2000, 0)
    for _, action in ipairs(res and res.result or {}) do
        if not action.edit then
            local resolved = client:request_sync('codeAction/resolve', action, 2000, 0)
            action = resolved and resolved.result or action
        end
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
    end
end

local function format()
    local ruff = vim.lsp.get_clients({ bufnr = 0, name = 'ruff' })[1]
    if ruff then
        organize_imports(ruff)
        vim.lsp.buf.format({ name = 'ruff' })
    else
        vim.lsp.buf.format()
    end
end

return {
    {
        'mason-org/mason.nvim',
        lazy = false,
        opts = {},
    },
    {
        'mason-org/mason-lspconfig.nvim',
        lazy = false,
        dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
        opts = { ensure_installed = { 'basedpyright', 'ruff' } },
        keys = {
            { '<leader>r', vim.lsp.buf.rename, desc = 'Rename Symbol' },
            { '<leader>a', vim.lsp.buf.code_action, mode = { 'n', 'x' }, desc = 'Quick Fix' },
            { '<leader>cf', format, desc = 'Format File' },
        },
    },
}
