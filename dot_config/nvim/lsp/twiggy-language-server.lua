return {
    cmd = { "twiggy-language-server", "--stdio" },
    filetypes = { "twig" },
    root_markers = { "composer.json", ".git" },
    settings = {
        twiggy = {
            file_name_pattern = "*.twig",
            default_path = vim.fn.getcwd() .. "/templates",
            namespaces = {
                root   = vim.fn.getcwd() .. "/templates",
                admin  = vim.fn.getcwd() .. "/templates/admin",
                site   = vim.fn.getcwd() .. "/templates/site",
                shared = vim.fn.getcwd() .. "/templates/shared",
            },
            framework = "symfony",
            phpExecutable = "php",
            symfonyConsolePath = "./bin/console",
            vanillaTwigEnvironmentPath = vim.fn.getcwd() .. "/templates",
            diagnostics = {
                twigCsFixer = true,
            },
        },
    },
}
