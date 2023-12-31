local M = {}

function M.replace_text(replacement)
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]

  local lines = vim.fn.join(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")

  local new_text = lines:gsub('https?://%g+', replacement)

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, vim.fn.split(new_text, "\n"))
end

return M
