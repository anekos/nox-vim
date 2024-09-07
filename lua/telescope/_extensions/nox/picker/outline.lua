local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

local config = require('telescope._extensions.nox.config')
local buffer = require('nox.buffer')

local outline = {}

local indent = function(s, n)
  return string.rep(' ', (n - 1) * 2) .. s
end

function outline.picker(opts)
  opts = opts or {}

  local results = buffer.headings()

  pickers
    .new(config.opts(opts), {
      prompt_title = 'Nox Outline',
      finder = finders.new_table {
        results = results,
        entry_maker = function(heading)
          return {
            value = heading,
            display = indent(heading.text, heading.level),
            ordinal = heading.line_number,
          }
        end,
      },
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr, _)
        -- Open the document
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry()
          vim.cmd(tostring(selection.value.line_number))
        end)

        return true
      end,
    })
    :find()
end

return outline
