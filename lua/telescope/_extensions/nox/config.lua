local config = {}

function config.endpoint(suffix)
  return vim.g.nox_endpoint .. suffix
end

function config.use_location_list()
  local raw = vim.g.nox_search_use_location_list
  return raw == nil or raw
end

function config.tasks_query()
  return vim.g.nox_tasks_query or ''
end

function config.opts(opts)
  opts = opts or {}
  return vim.tbl_deep_extend('force', config.defaults, opts)
end

config.defaults = {}

return config
