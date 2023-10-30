local previewers = require('telescope.previewers')

return previewers.new_buffer_previewer {
  title = 'Config',
  define_preview = function (self, entry, _)
    local id = entry.value

    local lines = vim.fn['nox#api#get_source'](id)

    if #lines == 0 then
      table.insert(lines, 'Empty')
    end

    vim.api.nvim_buf_set_lines(
      self.state.bufnr,
      0,
      -1,
      false,
      lines
    )
  end
}
