-- KIND ICON PROVIDERS --------------------------------------------------------
-------------------------------------------------------------------------------

-- Uses a simple hex matcher in completion docs to create a colored kind icon.
local function kind_icon_color_swatch_hex_only_hack()
    return {
        text = function(ctx)
            local doc = ctx.item.documentation
            local doc_str = type(doc) == 'string' and doc or (doc and doc.value) or ''
            local hex_color = doc_str:match '#%x%x%x%x%x%x'

            if hex_color then
                -- Build unique highlight group for color
                local hl_name = 'ColorSwatchIcon' .. hex_color:gsub('#', '')
                if vim.fn.hlID(hl_name) == 0 then
                    vim.api.nvim_set_hl(0, hl_name, { fg = hex_color })
                end
                -- Store highlight for this item
                ctx.tailwind_hl = hl_name
            end

            return '' .. ctx.icon_gap
        end,

        highlight = function(ctx)
            -- Return custom highlight for color, or force default for others
            return ctx.tailwind_hl or ('BlinkCmpKind' .. ctx.kind)
        end,
    }
end

-- BLINK.CMP CONFIG -----------------------------------------------------------
-------------------------------------------------------------------------------

return {
    'saghen/blink.cmp',
    enabled = true,
    build = 'cargo +nightly build --release',
    dependencies = {
        'rafamadriz/friendly-snippets',
    },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default',
            ['<C-y>'] = { 'select_and_accept' },
        },
        appearance = {
            nerd_font_variant = 'mono',
        },
        completion = {
            documentation = { auto_show = true },
            menu = {
                draw = {
                    components = {
                        kind_icon = kind_icon_color_swatch_hex_only_hack(),
                    },
                },
            },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        signature = { enabled = true },
        fuzzy = { implementation = 'prefer_rust_with_warning' },
        fallback = { 'lua' },
    },
    opts_extend = { 'sources.default' },
}
