local actions = require('telescope.actions')
local entry_display = require('telescope.pickers.entry_display')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local state = require('telescope.actions.state')
local telescope_conf = require('telescope.config').values

local api = require('telescope._extensions.nox.api')
local config = require('telescope._extensions.nox.config')
local previewer = require('telescope._extensions.nox.previewer')

local buffer = require('nox.buffer')

local search = {}

local displayer = entry_display.create {
  separator = ' ',
  items = {
    { width = 0.4 },
    { remaining = true },
  },
}

local function display_from_entry(entry)
  return displayer {
    { entry.value.source.title, 'TelescopeResultsNumber' },
    { entry.value.source.id, 'TelescopeResultsComment' },
  }
end

function search.picker(opts)
  opts = opts or {}

  local query = opts.query or ''

  local results = {}

  for _, hit in ipairs(api.search(query)) do
    table.insert(results, hit)
  end

  if #results == 0 then
    vim.notify('No results found', vim.log.levels.ERROR)
    return
  end

  if config.use_location_list() then
    local qf_entries = {}
    for _, hit in ipairs(results) do
      local path = vim.fn['nox#id#to_url'](hit.id)
      local qf = { filename = path, lnum = 1, col = 1, type = 'W' }
      table.insert(qf_entries, qf)
    end
    -- vim.fn.setloclist(vim.fn.winnr(), qf_entries)
    vim.fn.setqflist(qf_entries)
  end

  opts = config.opts()

  pickers
    .new(opts, {
      prompt_title = 'Nox Search',
      finder = finders.new_table {
        results = results,
        entry_maker = function(hit)
          return {
            value = hit,
            display = display_from_entry,
            ordinal = hit.source.title .. ' ' .. hit.id,
            path = vim.fn['nox#id#to_url'](hit.id),
          }
        end,
      },
      sorter = telescope_conf.generic_sorter(opts),
      previewer = previewer,
      attach_mappings = function(prompt_bufnr, map)
        -- Insert the link
        map({ 'i', 'n' }, '<C-l>', function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry()
          local hit = selection.value
          local parts = vim.fn.split(hit.source.title, '/')
          local text = '[' .. parts[#{ parts }] .. '](@' .. hit.source.ulid .. ')'
          buffer.insert_text(text)
        end)

        map({ 'i', 'n' }, '<C-e>', function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry()
          local hit = selection.value
          local keys = vim.api.nvim_replace_termcodes(':<C-u>NoxOpen ' .. hit.id, true, false, true)
          vim.api.nvim_feedkeys(keys, 'n', false)
        end)

        -- Open the document
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry()
          vim.cmd { cmd = 'NoxOpen', args = { selection.value.id } }
        end)

        return true
      end,
    })
    :find()
end

function search.command(params)
  return search.picker { query = params.args }
end

return search
