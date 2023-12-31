local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

local api = require('telescope._extensions.nox.api')
local config = require('telescope._extensions.nox.config')
local previewer = require('telescope._extensions.nox.previewer')

local search = {}

function search.picker(opts)
  opts = opts or {}

  local query = opts.query or ''

  local results = {}
  local ulids = {}

  for _, hit in ipairs(api.search(query)) do
    table.insert(results, hit.id)
    ulids[hit.id] = hit.source.ulid
  end

  if config.use_location_list() then
    local qf_entries = {}
    for _, id in ipairs(results) do
      local path = vim.fn['nox#id#to_url'](id)
      local qf = {filename = path, lnum = 1, col = 1, type = 'W'}
      table.insert(qf_entries, qf)
    end
    -- vim.fn.setloclist(vim.fn.winnr(), qf_entries)
    vim.fn.setqflist(qf_entries)
  end

  opts = config.opts()

  pickers.new(opts, {
    prompt_title = 'Nox Search',
    -- finder = results,
    finder = finders.new_table {
      results = results,
      entry_maker = function (id)
        return {
          value = id,
          display = id,
          ordinal = id,
          path = vim.fn['nox#id#to_url'](id)
        }
      end
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)

      -- Insert the link
      map('i', '<C-i>', function()
        actions.close(prompt_bufnr)
        local selection = state.get_selected_entry()
        local id = selection.value
        local parts = vim.fn.split(id, '/')
        local ulid = ulids[id]
        local text = '[' .. parts[#{parts}] .. '](@' .. ulid .. ')'
        vim.fn.append('.', text)
      end)

      -- Open the document
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = state.get_selected_entry()
        vim.cmd { cmd = 'NoxOpen', args = {selection.value} }
      end)

      return true
    end,
  }):find()
end

function search.command(params)
  return search.picker({query = params.args})
end

return search
