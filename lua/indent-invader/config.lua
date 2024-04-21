local M = {}

M.cursor_position = {
    start_of_line = 0,
    end_of_line = 1,
}

function M.merge_default_with_user(user_config)
    local default_config = {
        delete_command = {
            goto_next_line_after_delete = false,
            change_pos_after_delete = M.cursor_position.end_of_line,
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
