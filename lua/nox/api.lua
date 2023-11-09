local curl = require('plenary.curl')

local M = {}

function M.update_document_from_source(id, content, update_from)
  local query = { id = id }
  if update_from == nil then
    query['update_from'] = update_from
  end
  local resp = curl.request {
    url = vim.g.nox_endpoint .. '/api/source',
    method = 'put',
    query = query,
    body = vim.fn.json_encode(content),
    headers = {
      content_type = 'application/json',
    },
  }
  if resp.status ~= 200 then
    error('Failed to update')
  end
end

return M