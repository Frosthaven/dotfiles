return {
    cmd = { "twiggy-language-server", "--stdio" },
    filetypes = { "twig" },
    root_markers = { "composer.json", ".git" },
    settings = {
        twiggy = {
            autoInsertSpaces = true,            -- inside of {{ }} and {% %}
            inlayHints = {
                macroArguments = true,          -- {{ my_macro(arg1, arg2) }}
                macro = true,                   -- {% endmacro %} hints
                block = true,                   -- {% endblock %} hints
            },
            phpExecutable = "php",              -- path to php executable
            framework = "symfony",              -- symfony | craft | ignore
            symfonyConsolePath = "bin/console", -- path to symfony console
            diagnostics = {
                twigCsFixer = true,             -- enable diagnostics
            },
        },
    },
}
