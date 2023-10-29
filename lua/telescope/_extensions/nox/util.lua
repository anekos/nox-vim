local util = {}

local draft_prefix = 'draft/'

function util.new_id()
  local ids = get_drafts()
  local id_number = 0
  while true do
    id_number = id_number + 1
    local id = draft_prefix .. id_number
    if not ids[id] then
      return draft_prefix .. id_number
    end
  end
end

function util.get_drafts()
  local resp = curl.get(config.endpoint('/api/ids'), {
    query = {
      prefix = 'draft/',
    },
  })
  local ids = vim.fn.json_decode(resp.body)
  local results = {}
  for _, id in ipairs(ids) do
    results[id] = true
  end
  return results
end

return util
