local M = {}
local cmd = vim.cmd

-- Options
local opt = {
    show_diagnostic_number = true
}

M.find_line_diagnostic = function(show_entire_diagnostic)
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    local msg = ""
    if not vim.tbl_isempty(diagnostics) then
        for k, _ in pairs(diagnostics) do
            if diagnostics[k].message then
                if opt.show_diagnostic_number then
                    msg = msg .. k .. ": "
                end
                msg = msg .. diagnostics[k].message
                if k < #diagnostics then
                    msg = msg .. "\n"
                end
            end
        end
        -- Check height of message
        local height = vim.api.nvim_get_option('cmdheight')
        local tbl = vim.split(msg, "\n")

        -- Check if we should echo entire diagnostic
        if show_entire_diagnostic then
            if #tbl <= height then
                msg = msg .. string.rep("\n", (height - #tbl) + 1)
            end
            return msg
        end

        if #tbl > height then
            msg = table.concat(tbl, "\n", 1, height) .. " ..."
        end

        -- Check width of mesasge
        local winmargin = 20
        local windowlen = vim.api.nvim_get_option('columns')
        if (#msg / (windowlen - winmargin)) > height then
            -- Remove last part of message and add ' ...' to indicate that the msg is truncated
            msg = string.sub(msg, 1, (height * windowlen) - winmargin) .. ' ...'
        end
        return msg
    end
    return nil
end

M.echo_line_diagnostic = function()
    if not require('echo-diagnostics').find_line_diagnostic(false) then
        return
    end
    cmd([[echo luaeval('require("echo-diagnostics").find_line_diagnostic(false)')]])
    cmd([[autocmd CursorMoved * ++once echo " "]])
end

M.echo_entire_diagnostic = function()
    if not require('echo-diagnostics').find_line_diagnostic(true) then
        return
    end
    cmd([[echo luaeval('require("echo-diagnostics").find_line_diagnostic(true)')]])
    cmd([[autocmd CursorMoved * ++once echo " "]])
end

M.setup = function(user_options)
    opt = vim.tbl_extend('force', opt, user_options)
end

return M
