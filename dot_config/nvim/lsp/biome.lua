return {
    cmd = function()
        -- Try to find project-local biome first
        local root = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
            upward = true,
            path = vim.fn.getcwd(),
        })[1]
        if root then
            local project_dir = vim.fn.fnamemodify(root, ':h')
            local local_biome = project_dir .. '/node_modules/.bin/biome'
            if vim.fn.executable(local_biome) == 1 then
                return { local_biome, 'lsp-proxy' }
            end
        end
        return { 'biome', 'lsp-proxy' }
    end,
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "css",
    },
    root_markers = { "biome.json", "biome.jsonc" },
    single_file_support = false,
}
