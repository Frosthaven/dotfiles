return {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "astro",
        "vue",
        "twig",
        "php",
        "heex",
    },
    root_markers = { ".git" },
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
                cssConflict = "warning", -- or "error", "ignore"
                invalidApply = "error",
                invalidConfigPath = "error",
                invalidScreen = "error",
                invalidTailwindDirective = "error",
                unknownAtRules = "ignore", -- or "error", "warning"
                unknownClasses = "error",
            },
            experimental = {
                configFile = {
                    -- new project layout
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
                },
                classRegex = {
                    -- 1) Twig `{% set name = '...' %}`:
                    { [[{%\s*set\s+\w+\s*=\s*([^%]*)%}]], [[(?:'|")([^'"]*)(?:'|")]] },
                },
            },
        },
    }
}
