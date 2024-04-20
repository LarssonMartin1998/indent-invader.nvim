local M = {}

function M.merge_default_with_user(user_config, keymaps)
    local default_config = {
        clean_command = {
            fallback_to_regular_backspace = false,
        },
        delete_command = {
            goto_previous_line_after_delete = true,
            goto_end_of_line_after_delete = true,
            fallback_to_regular_backspace = true,
        },
        should_create_keymaps = true,
    }

    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    return M.config
end

function M.get(subkey)
    if subkey then
        return M.config[subkey]
    end

    return M.config
end

return M
