local api = require('nox.api')

local M = {}

function M.on_buf_write_cmd(url)
  local id = vim.fn['nox#id#from_url'](url)

  local updated_at = vim.fn['nox#buffer#get_attribute']('updated-at')
  if updated_at == vim.NIL then
    updated_at = vim.fn.strftime('Mon, 05 Feb 2024 11:26:38 +0900')
  end
  updated_at = vim.fn['nox#util#datetime_to_api_format'](updated_at)

  vim.fn['nox#buffer#pre']()

  local buffer_content = vim.fn.join(vim.fn.getline(1, '$'), "\n")
  if vim.b.nox_new_buffer then
    api.new_document_from_source(id, buffer_content)
    vim.b.nox_new_buffer = false
  else
    api.update_document_from_source(id, buffer_content, updated_at)
  end

  vim.cmd.setlocal('nomodified')
end

return M
