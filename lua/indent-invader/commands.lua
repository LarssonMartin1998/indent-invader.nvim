local M = {}

local commands_name_prefix = "IndentInvader"
local command_names = {
    "Delete",
    "Clean",
}

local function delete()
    print("Delete")
end

local function clean()
    print("Clean")
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
