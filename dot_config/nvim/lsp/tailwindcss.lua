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
                configFile = {
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
                },
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
