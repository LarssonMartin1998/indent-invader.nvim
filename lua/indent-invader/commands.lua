local config = require("indent-invader.config")

local M = {}

local commands_name_prefix = "IndentInvader"
local command_names = {
    "Delete",
    "Clean",
}

local line_state = {
    completely_empty = 0,
    only_has_whitespaces = 1,
    has_content = 2,
}

local function get_line_state(line)
    local is_completely_empty = string.len(line) == 0
    if is_completely_empty then
        return line_state.completely_empty
    end

    local only_has_whitespaces = line:match("^%s+$")
    if only_has_whitespaces then
        return line_state.only_has_whitespaces
    end

    return line_state.has_content
end

local function perform_fallback_backspace()
    local bufnr = 0 -- Buffer number, 0 refers to the current buffer
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1   -- Convert to 0-based indexing for rows

    if col > 0 then
        -- Get the current line's text
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
        -- Remove the character before the cursor
        local new_line = line:sub(1, col - 1) .. line:sub(col + 1)
        -- Set the new line text
        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, true, { new_line })
        -- Move the cursor back one character
        vim.api.nvim_win_set_cursor(0, { row + 1, col - 1 })
    end
end

local function handle_line(should_fallback_to_regular_backspace, line_action)
    local current_line = vim.api.nvim_get_current_line()
    local state = get_line_state(current_line)

    if state ~= line_state.only_has_whitespaces then
        if should_fallback_to_regular_backspace then
            perform_fallback_backspace()
        end

        return
    end

    line_action()
end

local function delete()
    local delete_config = config.get("delete_command")
    handle_line(delete_config.fallback_to_regular_backspace, function()
        local line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, {})

        local targer_cursor_line = line_number
        if delete_config.goto_previous_line_after_delete then
            targer_cursor_line = targer_cursor_line - 1
        end

        local target_cursor_char_index = 0
        if delete_config.change_pos_after_delete ~= nil then
            if delete_config.change_pos_after_delete == config.cursor_position.start_of_line then
                target_cursor_char_index = 0
            else
                target_cursor_char_index = string.len(vim.api.nvim_buf_get_lines(0, targer_cursor_line,
                    targer_cursor_line + 1, false)[1])
            end
        end

        vim.api.nvim_win_set_cursor(0, { targer_cursor_line + 1, target_cursor_char_index })
    end)
end

local function clean()
    local clean_config = config.get("clean_command")
    handle_line(clean_config.fallback_to_regular_backspace, function()
        local line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, {})
    end)
end

function M.get_delete_command_name()
    return commands_name_prefix .. command_names[1]
end

function M.get_clean_command_name()
    return commands_name_prefix .. command_names[2]
end

function M.create_user_commands()
    local commands = {
        { M.get_delete_command_name(), delete },
        { M.get_clean_command_name(),  clean },
    }

    for _, command in ipairs(commands) do
        vim.api.nvim_create_user_command(command[1], command[2], {})
    end
end

return M
