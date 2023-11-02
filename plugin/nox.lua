local command = require('nox.command')

vim.api.nvim_create_user_command(
  'NoxOgp',
  function (opts)
    command.ogp(opts.args)
  end,
  {
    nargs = '*',
    complete = 'customlist,nox#completion#ogp_format',
    range = true,
  }
)
