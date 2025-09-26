return { -- Automatic tag closing
  'windwp/nvim-ts-autotag',
  opts = {
      opts = {
          -- Defaults
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
      },
  },
  per_filetype = {
      -- ['html'] = {
      --     enable_close = false,
      -- },
  },
}
