local api = require('nox.api')

local M = {}

function M.on_buf_write_cmd(url)
  local id = vim.fn['nox#id#from_url'](url)

  local created_at = vim.b.nox_created_at
  local updated_at = vim.b.nox_updated_at

  vim.fn['nox#buffer#pre']()

  local buffer_content = vim.fn.join(vim.fn.getline(1, '$'), "\n")
  if vim.b.nox_new_buffer then
    api.new_document_from_source(id, buffer_content)
    vim.b.nox_new_buffer = false
  else
    local result = api.update_document_from_source(id, buffer_content, created_at, updated_at)
    print(vim.inspect(result))
  end

  vim.cmd.setlocal('nomodified')
end

return M
