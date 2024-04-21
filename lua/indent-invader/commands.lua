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

local function set_line(row, strict_indexing, replacement)
    vim.api.nvim_buf_set_lines(0, row, row + 1, strict_indexing, replacement)
end

local function delete_line(row, strict_indexing)
    set_line(row, strict_indexing, {})
end

local function set_cursor(row, col)
    vim.api.nvim_win_set_cursor(0, { row, col })
end

local function get_line(row)
    return vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
end

local function perform_fallback_backspace()
    local bs = vim.api.nvim_replace_termcodes('<BS>', true, true, true)
    vim.api.nvim_feedkeys(bs, 'ni', true)
end

local function handle_line_command(line_action)
    local current_line = vim.api.nvim_get_current_line()
    local state = get_line_state(current_line)

    if state ~= line_state.only_has_whitespaces then
        perform_fallback_backspace()
        return
    end

    line_action()
end

local function delete()
    local delete_config = config.get("delete_command")
    handle_line_command(function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1 -- Convert to 0-based index
        delete_line(row, true)

        if delete_config.goto_next_line_after_delete then
            row = row + 1
        end

        if delete_config.change_pos_after_delete == config.cursor_position.start_of_line then
            col = 0

            local new_line = get_line(row - 1)
            for i = 1, string.len(new_line) do
                if not string.match(string.sub(new_line, i, i), "%s") then
                    col = i - 1
                    break
                end
            end
        else
            local new_line = get_line(row - 1)
            col = string.len(new_line)
        end

        set_cursor(row, col)
    end)
end

local function clean()
    handle_line_command(function()
        -- local line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
        -- vim.api.nvim_buf_set_lines(0, line_number, line_number + 1, false, {})
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
