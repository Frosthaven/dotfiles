return {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
        local npairs = require 'nvim-autopairs'
        local Rule = require 'nvim-autopairs.rule'

        npairs.setup {
            check_ts = true,
        }

        -- Twig {%  %}
        npairs.add_rule(Rule('{%', '%}')
            :with_pair(function()
                return true
            end)
            :replace_endpair(function()
                -- existing pairing rules already created } by this point
                -- so we just need to add the ' %' before the generated }
                return ' %'
            end)
            :use_key '%')

        -- Twig {#  #}
        npairs.add_rule(Rule('{#', '#}')
            :with_pair(function()
                return true
            end)
            :replace_endpair(function()
                -- existing pairing rules already created } by this point
                -- so we just need to add the ' #' before the generated }
                return ' #'
            end)
            :use_key '#')
    end,
}
