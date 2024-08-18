local previewers = require('telescope.previewers')

return previewers.new_buffer_previewer {
  title = 'Config',
  define_preview = function(self, entry, _)
    local hit = entry.value
    local lines = vim.split(hit.source.text, '\n')

    if lines == vim.NIL then
      lines = { 'Empty' }
    end

    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
  end,
}
