local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')

local config = require('telescope._extensions.nox.config')
local buffer = require('nox.buffer')

local outline = {}
local reject_chars = vim.trim([[ [^[:alnum:][:space:]-\u3000-\u30ff\u4e00-\u9fff] ]])

local indent = function(s, n)
  return string.rep(' ', (n - 1) * 2) .. s
end

local to_anchor_id = function(s)
  s = vim.fn.substitute(s, reject_chars, '', 'g')
  return vim.trim(s:lower():gsub(' ', '-'))
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
            ordinal = heading.text,
          }
        end,
      },
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr, map)
        -- Open the document
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local heading = state.get_selected_entry().value
          vim.cmd(tostring(heading.line_number))
        end)

        -- Insert the link
        map({ 'i', 'n' }, '<C-l>', function()
          actions.close(prompt_bufnr)
          local heading = state.get_selected_entry().value
          local link = '[' .. heading.text .. '](#mkd-' .. to_anchor_id(heading.text) .. ')'
          buffer.insert_text(link)
        end)

        return true
      end,
    })
    :find()
end

return outline
