local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

local api = require('telescope._extensions.nox.api')
local config = require('telescope._extensions.nox.config')

local tasks = {}

local search = function (opts, query)
  local q = query .. ' #todo @section'

  local results = {}
  local ulids = {}

  for _, hit in pairs(api.search(q)) do
    table.insert(results, {
      document = true,
      id = hit.id,
      ulid = hit.source.ulid,
      display = hit.id,
    })

    for _, task in pairs(hit.source.task) do
      table.insert(results, {
        document = false,
        id = hit.id,
        ulid = hit.source.ulid,
        display = '  ' .. task.label,
      })
    end
    ulids[hit.id] = hit.source.ulid
  end

  if config.use_location_list() then
    local qf_entries = {}
    for _, task in ipairs(results) do
      if task.document then
        local path = vim.fn['nox#id#to_url'](task.id)
        local qf = {filename = path, lnum = 1, col = 1, type = 'W'}
        table.insert(qf_entries, qf)
      end
    end
    vim.fn.setloclist(vim.fn.winnr(), qf_entries)
  end

  pickers.new(config.opts(opts), {
    prompt_title = 'Nox Tasks',
    -- finder = results,
    finder = finders.new_table {
      results = results,
      entry_maker = function (task)
        local id = task.id
        return {
          value = id,
          display = task.display,
          ordinal = task.display .. ' ' .. task.id,
          path = vim.fn['nox#id#to_url'](id)
        }
      end
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
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

function tasks.picker(opts)
  return search(config.opts(opts), config.tasks_query())
end

function tasks.command(params)
  return search(config.opts(), params.args)
end

vim.api.nvim_create_user_command(
  'NoxTasks',
  tasks.command,
  {
    nargs = "*",
    complete = "customlist,nox#completion#related"
  }
)

return tasks
