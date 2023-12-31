local curl = require('plenary.curl')

local config = require('telescope._extensions.nox.config')

local api = {}

local headers = function ()
  local result = {}
  result['x-password'] = vim.g.nox_password
  return result
end

function api.search(query)
  local resp = curl.get(config.endpoint('/api/search'), {
    query = {
      query = query,
    },
    headers = headers(),
  })

  return vim.fn.json_decode(resp.body).hits
end

function api.similar(id)
  local resp = curl.get(config.endpoint('/api/document/similarities'), {
    query = {
      id = id,
    },
    headers = headers(),
  })

  return vim.fn.json_decode(resp.body).hits
end

return api
