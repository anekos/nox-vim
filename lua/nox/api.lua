local curl = require('plenary.curl')

local M = {}

-- Private {{{

local make_headers = function()
  local headers = {
    content_type = 'application/json',
  }

  if vim.g.nox_password ~= nil then
    headers['x-password'] = vim.g.nox_password
  end

  return headers
end

local vanish = function(tbl)
  local result = {}
  for key, value in pairs(tbl) do
    if value ~= nil then
      result[key] = value
    end
  end
  return result
end

local request = function(method, path, query, body)
  local body_file = nil

  if body ~= nil then
    body_file = vim.fn.tempname()
    vim.fn.writefile({ vim.fn.json_encode(body) }, body_file)
  end

  local resp = curl.request {
    url = vim.g.nox_endpoint .. path,
    method = method,
    query = (query and vanish(query)),
    body = body_file,
    headers = make_headers(),
  }

  if resp.status ~= 200 then
    error('Failed to update')
  end

  if body_file ~= nil then
    vim.fn.delete(body_file)
  end

  return vim.fn.json_decode(resp.body)
end

-- }}}

function M.meta(id, update)
  return request('get', '/api/meta', vanish { id = id, update = update })
end

function M.new_document_from_source(id, source, meta)
  local params = { id = id, sync = '1' }
  local body = { source = source, meta = meta }
  return request('post', '/api/source', vanish(params), body)
end

function M.update_document_from_source(id, source, meta, update_from)
  local params = { id = id, update_from = update_from, sync = '1' }
  local body = { source = source, meta = meta }
  return request('put', '/api/source', vanish(params), body)
end

function M.resolve_ulid(ulid)
  return request('get', '/api/ulid', vanish { ulid = ulid })
end

return M
