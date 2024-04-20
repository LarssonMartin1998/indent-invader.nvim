local M = {}

function M.setup(opts)
    local commands = require("indent-invader.commands")
    commands.setup_commands()
end

return M
