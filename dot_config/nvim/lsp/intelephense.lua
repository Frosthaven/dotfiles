return {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
    settings = {
        intelephense = {
            files = {
                maxSize = 5000000, -- 5 MB max file size
            },
            environment = {
                includePaths = {
                    vim.fn.getcwd() .. "/src",
                    vim.fn.getcwd() .. "/vendor",
                },
            },
            diagnostics = {
                enable = true,
                maxNumberOfProblems = 100,
            },
            formatting = {
                enable = true,
            },
            stubs = {
                "apache", "bcmath", "bz2", "calendar", "Core", "ctype", "curl",
                "date", "dba", "dom", "enchant", "exif", "FFI", "fileinfo",
                "filter", "fpm", "ftp", "gd", "gettext", "gmp", "hash", "iconv",
                "imap", "intl", "json", "ldap", "libxml", "mbstring", "mcrypt",
                "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO",
                "pdo_mysql", "pdo_pgsql", "pgsql", "Phar", "posix", "pspell",
                "readline", "recode", "Reflection", "session", "shmop",
                "SimpleXML", "soap", "sockets", "sodium", "SPL", "sqlite3",
                "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm",
                "tidy", "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter",
                "xsl", "Zend OPcache", "zip", "zlib",
            },
            filesExclude = {
                "**/.git/**",
                "**/vendor/**/{Tests,test}/**",
                "**/node_modules/**",
                "**/var/cache/**",
                "**/var/log/**",
            },
        },
    },
}
