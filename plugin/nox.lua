local buffer = require('nox.buffer')

vim.api.nvim_create_user_command(
  'NoxOgp',
  function (opts)
    buffer.convert_url(opts.args)
  end,
  {
    nargs = '*',
    complete = 'customlist,nox#completion#ogp_format',
    range = true,
  }
)
