local config = require("indent-invader.config")
local keymaps = require("indent-invader.keymaps")
local commands = require("indent-invader.commands")

local M = {}

function M.setup(opts)
    opts = opts or {}

    local user_keymaps = opts.keymaps
    opts.keymaps = nil

    local merged_config = config.merge_default_with_user(opts)
    if merged_config.should_create_keymaps then
        local merged_keymaps = keymaps.merge_default_with_user(user_keymaps)
        keymaps.create_bindings(merged_keymaps)
    end

    commands.create_user_commands()
end

return M
