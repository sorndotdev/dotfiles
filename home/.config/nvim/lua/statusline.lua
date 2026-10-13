local M = {}

local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    R = "REPLACE",
    t = "TERMINAL",
    s = "SELECT",
}

local hl = vim.api.nvim_set_hl
hl(0, "StatusEdge", { fg = "#808000", bg = "#FFFEF8" })
hl(0, "StatusMode", { fg = "#FFFEF8", bg = "#0000C0", bold = true })
hl(0, "StatusFile", { fg = "#0000C0", bg = "#FFFEF8" })
hl(0, "StatusInfo", { fg = "#008080", bg = "#FFFEF8" })
hl(0, "StatusSep", { fg = "#808080", bg = "#FFFEF8" })
hl(0, "StatusPos", { fg = "#FFFEF8", bg = "#7F0055", bold = true })

local function escape(text)
    return (text:gsub("%%", "%%%%"))
end

function M.render()
    local label = modes[vim.api.nvim_get_mode().mode] or "NORMAL"
    local name = vim.api.nvim_buf_get_name(0)
    name = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
    local modified = vim.bo.modified and " [+]" or ""
    local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "text"

    return table.concat({
        "%#StatusEdge#\u{258c}",
        "%#StatusMode# ", label, " ",
        "%#StatusEdge#\u{258c}",
        "%#StatusFile# ", escape(name), modified, " ",
        "%=",
        "%#StatusInfo# ", filetype, " ",
        "%#StatusSep#\u{2502}",
        "%#StatusPos# %l:%c %p%% ",
    })
end

return M
