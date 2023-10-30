local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

local config = require('telescope._extensions.nox.config')

local outline = {}

local indent = function (s, n)
  return string.rep(' ', (n - 1) * 2) .. s
end

function outline.picker(opts)
  opts = opts or {}

  -- get buffer lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local results = {}

  for i, line in pairs(lines) do
    if string.match(line, '^#') then
      local level = string.match(line, '^#+')
      level = string.len(level)
      line = string.gsub(line, '^#+%s*', '')
      table.insert(results, {level = level, text = line, lnum = i})
    end
  end

  pickers.new(config.opts(opts), {
    prompt_title = 'Nox Outline',
    finder = finders.new_table {
      results = results,
      entry_maker = function (heading)
        return {
          value = heading,
          display = indent(heading.text, heading.level),
          ordinal = heading.text,
        }
      end
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      -- Open the document
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = state.get_selected_entry()
        vim.cmd(tostring(selection.value.lnum))
      end)

      return true
    end,
  }):find()
end

return outline
