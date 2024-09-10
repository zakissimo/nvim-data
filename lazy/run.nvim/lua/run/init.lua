local M = {}

M.setup = {
    input_map = "<Leader>mm"
}

M.previous_input = {}

M.cmd = function ()
    local prompt = "Insert Command: "
    local bufmap = vim.api.nvim_buf_set_keymap
    local bufnr = vim.api.nvim_get_current_buf()

    vim.ui.input({ prompt = prompt,
        default = M.previous_input[bufnr],
        completion = "file" },
        function(input)
        if input then
            bufmap(0, "n", M.setup.input_map,
                ":w<CR>:!" .. input .. "<CR>", { noremap = true })
            M.previous_input[bufnr] = input
        end
    end)
end

return M
