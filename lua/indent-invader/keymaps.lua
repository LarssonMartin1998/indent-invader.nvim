local commands = require("indent-invader.commands")

local M = {}

function M.merge_default_with_user(user_keymaps)
    user_keymaps = user_keymaps or {}
    local defaul_keymaps = {
        { "i", "<BS>",   "<cmd>" .. commands.get_delete_command_name() .. "<CR>" },
        { "i", "<S-BS>", "<cmd>" .. commands.get_clean_command_name() .. "<CR>" },
    }

    return vim.tbl_deep_extend("force", defaul_keymaps, user_keymaps)
end

function M.create_bindings(keymaps)
    for _, key in ipairs(keymaps) do
        vim.api.nvim_set_keymap(key[1], key[2], key[3], { noremap = true, silent = true })
    end
end

return M
