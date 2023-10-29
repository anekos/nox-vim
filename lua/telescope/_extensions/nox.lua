local telescope_installed, telescope = pcall(require, 'telescope')

if not telescope_installed then
    error('This plugin requires nvim-telescope/telescope.nvim')
end

local config = require('telescope._extensions.nox.config')
local outline = require('telescope._extensions.nox.picker.outline')
local search = require('telescope._extensions.nox.picker.search')
local similar = require('telescope._extensions.nox.picker.similar')
local tasks = require('telescope._extensions.nox.picker.tasks')


vim.api.nvim_create_user_command(
  'NoxSearch',
  search.command,
  {
    nargs = "*",
    complete = "customlist,nox#completion#related"
  }
)

return telescope.register_extension({
  setup = function(ext_conf, conf)
    config.defaults = vim.tbl_deep_extend('force', conf, ext_conf)
  end,
  exports = {
    nox = search.picker,
    outline = outline.picker,
    search = search.picker,
    similar = similar.picker,
    tasks = tasks.picker,
  },
})
