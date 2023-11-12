local command = require('nox.command')
local autocmd = require('nox.autocmd')

vim.api.nvim_create_user_command('NoxOgp', function(opts)
  command.ogp(opts.args)
end, {
  nargs = '*',
  complete = 'customlist,nox#completion#ogp_format',
  range = true,
})

local au_group = vim.api.nvim_create_augroup('NoxPluginLua', {})

vim.api.nvim_create_autocmd('BufWriteCmd', {
  group = au_group,
  pattern = 'nox://*',
  callback = function(ev)
    autocmd.on_buf_write_cmd(ev.file)
  end,
})
