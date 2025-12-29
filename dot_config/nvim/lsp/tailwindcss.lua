-- Tailwind CSS v4 config file mappings
-- Each entry maps a CSS entrypoint to glob patterns for files that use it
local config_file_mappings = {
    -- iww-project-skeleton
    ['assets/site.tailwind.css'] = {
        'assets/react/site/**',
        'src/Controller/Site/**',
        'templates/site/**',
    },
    ['assets/admin.tailwind.css'] = {
        'assets/react/admin/**',
        'src/Controller/Admin/**',
        'templates/admin/**',
        'templates/bundles/EasyAdminBundle/**',
    },
    -- skeleton-website-framework
    ['tailwind.2.admin.css'] = {
        'assets/local-assets/react/admin/**',
        'templates/admin/**',
        'templates/bundles/EasyAdminBundle/**',
        'src/Controller/Admin/**',
    },
    ['tailwind.1.app.css'] = {
        '**/*',
    },
    -- tanstack start
    ['src/styles.css'] = {
        'src/**',
    },
}

--- Builds the configFile table by checking which CSS files exist in the root
---@param root_dir string The root directory of the project
---@return table|nil configFile table or nil if no files found
local function build_config_file(root_dir)
    local result = {}
    local found_any = false

    for css_path, globs in pairs(config_file_mappings) do
        local full_path = root_dir .. '/' .. css_path
        local stat = vim.uv.fs_stat(full_path)
        if stat and stat.type == 'file' then
            result[css_path] = globs
            found_any = true
        end
    end

    -- Return nil if no config files found, letting LSP use auto-detection
    return found_any and result or nil
end

return {
    cmd = { 'tailwindcss-language-server', '--stdio' },
    filetypes = {
        'html',
        'css',
        'scss',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
        'astro',
        'vue',
        'twig',
        'php',
        'heex',
    },
    root_markers = {
        'tailwind.config.js',
        'tailwind.config.cjs',
        'tailwind.config.mjs',
        'tailwind.config.ts',
        'postcss.config.js',
        'postcss.config.cjs',
        'postcss.config.mjs',
        'postcss.config.ts',
        'package.json',
        '.git',
    },
    on_init = function(client)
        -- Dynamically build configFile based on files that exist in the project
        local root_dir = client.root_dir or vim.fn.getcwd()
        local config_file = build_config_file(root_dir)

        if config_file then
            -- Deep merge into existing settings
            client.settings = vim.tbl_deep_extend('force', client.settings or {}, {
                tailwindCSS = {
                    experimental = {
                        configFile = config_file,
                    },
                },
            })
            -- Notify the server of the updated settings
            client:notify('workspace/didChangeConfiguration', {
                settings = client.settings,
            })
        end

        return true
    end,
    settings = {
        tailwindCSS = {
            colorDecorators = true,
            includeLanguages = {
                elixir = 'phoenix-heex',
                heex = 'phoenix-heex',
                html = 'html',
                javascript = 'javascript',
                javascriptreact = 'javascriptreact',
                typescript = 'typescript',
                typescriptreact = 'typescriptreact',
                svelte = 'svelte',
                vue = 'vue',
                twig = 'html',
            },
            lint = {
                cssConflict = 'warning', -- or "error", "ignore"
                invalidApply = 'error',
                invalidConfigPath = 'error',
                invalidScreen = 'error',
                invalidTailwindDirective = 'error',
                unknownAtRules = 'ignore', -- or "error", "warning"
                unknownClasses = 'error',
            },
            experimental = {
                -- configFile is dynamically set in on_init based on existing files
                classRegex = {
                    -- 1) Twig variable sets:
                    -- {% set name = '...' %}
                    { [[{%\s*set\s+\w+\s*=\s*([^%]*)%}]], [[(?:'|")([^'"]*)(?:'|")]] },
                    -- 2) Twig key/value pairs:
                    -- key: '...'
                    { [[\w+:\s*(['"`][^'"`]+['"`])]], [[([^'"`]+)]] },
                    -- 3) All string literals
                    -- '...', "...", `...`
                    { [[(['"`][^'"`]+['"`])]], [[([^'"`]+)]] },
                },
            },
        },
    },
}
