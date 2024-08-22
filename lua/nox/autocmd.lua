local api = require('nox.api')

local M = {}

function M.on_buf_read_cmd(url)
  local id = vim.fn['nox#id#from_url'](url)
  local result = vim.fn['nox#api#get_source_with_meta'](id)
  vim.o.filetype = 'nox'

  if result == vim.NIL then
    vim.b.nox_meta = api.meta(id, 0)
    vim.fn['nox#buffer#new'](id)
    vim.b.nox_new_buffer = true
    return
  end

  vim.b.nox_new_buffer = false
  vim.fn.setline(1, result.source)
  vim.b.nox_meta = result.meta
end

function M.on_buf_write_cmd(url)
  local id = vim.fn['nox#id#from_url'](url)

  local old_meta = vim.b.nox_meta

  local buffer_content = vim.fn.join(vim.fn.getline(1, '$'), "\n")
  if vim.b.nox_new_buffer then
    api.new_document_from_source(id, buffer_content, old_meta)
    vim.b.nox_new_buffer = false
  else
    local new_meta = api.meta(id, 1)
    api.update_document_from_source(id, buffer_content, new_meta, old_meta.updated_at)
    vim.b.nox_meta = new_meta
  end

  vim.cmd.setlocal('nomodified')
end

return M
