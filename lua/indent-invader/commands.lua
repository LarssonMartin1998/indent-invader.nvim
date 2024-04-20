local M = {}

local function delete()
    print("Delete")
end
local function clean()
    print("Clean")
end

function M.setup_commands()
    local command_name_prefix = "IndentInvader"
    local commands = {
        { "Delete", delete },
        { "Clean",  clean },
    }

    for _, command in ipairs(commands) do
        local command_name = command_name_prefix .. command[1]
        vim.api.nvim_create_user_command(command_name, command[2], {})
    end
end

return M
