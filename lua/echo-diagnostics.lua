local M = {}
local cmd = vim.cmd

-- Options
local opt = {
    show_diagnostic_number = true,
    show_diagnostic_source = false,
}

M.find_line_diagnostic = function(show_entire_diagnostic)
    local has_vim_diagnostic = vim.diagnostic ~= nil
    local diagnostics = {}
    -- Check if they have the new API for diagnostic and use that if they do.
    if has_vim_diagnostic then
        local lnum, _ = unpack(vim.api.nvim_win_get_cursor(0))
        diagnostics = vim.diagnostic.get(0, { lnum = lnum - 1 })
    else
        diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    end

    local full_msg = ''
    local trunc_msg = ''

    local winmargin = 20
    local used_height = 0

    local windowlen = vim.api.nvim_get_option('columns')
    local cmdheight = vim.api.nvim_get_option('cmdheight')

    if not vim.tbl_isempty(diagnostics) then
        for k, _ in pairs(diagnostics) do
            if diagnostics[k].message then
                local msg = ''

                if opt.show_diagnostic_number then
                    msg = msg .. k .. ': '
                end
                msg = msg .. diagnostics[k].message
                if opt.show_diagnostic_source and diagnostics[k].source then
                    msg = msg .. ' (' .. diagnostics[k].source .. ')'
                end

                if k < #diagnostics then
                    full_msg = full_msg .. msg .. '\n'
                else
                    full_msg = full_msg .. msg
                end

                -- Diagnostic sent from language server may contain newlines
                local lines = vim.split(msg, '\n')
                for i, line in ipairs(lines) do
                    -- Check how many rows the diagnostics currently will fill
                    local remaining_height = cmdheight - used_height
                    local msg_height = math.ceil(#line / windowlen)
                    local max_len = remaining_height * windowlen - winmargin

                    if used_height + msg_height < cmdheight then
                        trunc_msg = trunc_msg .. line
                        -- Avoid edge case where the appended newline would create
                        -- a prompt of press enter to continue.
                        if #line ~= windowlen then
                            trunc_msg = trunc_msg .. '\n'
                        end
                    else
                        trunc_msg = trunc_msg .. string.sub(line, 1, max_len)
                        -- Append ... if more diagnostics exists or current msg is too long
                        if #diagnostics > k or #lines > i or #line > max_len then
                            trunc_msg = trunc_msg .. ' ...'
                        end
                        if not show_entire_diagnostic then
                            return trunc_msg
                        end
                    end
                    used_height = used_height + msg_height
                end
            end
        end

        -- Check if we should echo entire diagnostic
        if show_entire_diagnostic then
            local tbl = vim.split(full_msg, '\n')
            if #tbl <= cmdheight then
                full_msg = full_msg .. string.rep('\n', (cmdheight - #tbl) + 1)
            end
            return full_msg
        end

        return trunc_msg
    end
    return nil
end

M.echo_line_diagnostic = function()
    if not require('echo-diagnostics').find_line_diagnostic(false) then
        return
    end
    vim.api.nvim_echo({ { require('echo-diagnostics').find_line_diagnostic(false) } }, false, {})
    cmd([[autocmd CursorMoved * ++once echo " "]])
end

M.echo_entire_diagnostic = function()
    if not require('echo-diagnostics').find_line_diagnostic(true) then
        return
    end
    vim.api.nvim_echo({ { require('echo-diagnostics').find_line_diagnostic(true) } }, false, {})
    cmd([[autocmd CursorMoved * ++once echo " "]])
end

M.setup = function(user_options)
    user_options = user_options or {}
    opt = vim.tbl_extend('force', opt, user_options)
end

return M
