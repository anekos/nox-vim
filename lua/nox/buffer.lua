local M = {}

function M.replace_text(replacement)
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]

  local lines = vim.fn.join(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), '\n')

  local new_text = lines:gsub('https?://%g+', replacement)

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, vim.fn.split(new_text, '\n'))
end

local function get_syntax_name(line, col)
  local syn_id = vim.fn.synID(line, col, 1)
  return vim.fn.synIDattr(syn_id, 'name')
end

local function get_syntax_range(line, col)
  local syn_name = get_syntax_name(line, col)

  -- print('syn_name: ' .. syn_name)

  if syn_name == '' then
    -- print('No syntax group found under cursor')
    return nil
  end

  local start_line, start_col = line, col
  while true do
    if start_col > 1 then
      start_col = start_col - 1
    elseif start_line > 1 then
      start_line = start_line - 1
      start_col = vim.fn.col { start_line, '$' }
    else
      break
    end
    local current_syn_id = vim.fn.synID(start_line, start_col, 1)
    if vim.fn.synIDattr(current_syn_id, 'name') ~= syn_name then
      start_col = start_col + 1
      break
    end
  end

  local end_line, end_col = line, col
  local last_line = vim.fn.line('$')
  while true do
    if end_col < vim.fn.col { end_line, '$' } then
      end_col = end_col + 1
    elseif end_line < last_line then
      end_line = end_line + 1
      end_col = 1
    else
      break
    end
    local current_syn_id = vim.fn.synID(end_line, end_col, 1)
    if vim.fn.synIDattr(current_syn_id, 'name') ~= syn_name then
      end_col = end_col - 1
      break
    end
  end
  return syn_name, start_line, start_col, end_line, end_col
end

local function get_range_text(start_line, start_col, end_line, end_col)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_text(bufnr, start_line - 1, start_col - 1, end_line - 1, end_col, {})

  if #lines > 0 then
    return table.concat(lines, '\n')
  end

  return nil
end

local function is_heading(name)
  return name:match('markdownH%dDelimiter') or name == 'mkdHeading'
end

local function search_link_syntax(line, col, n)
  if not n then
    error('get_syntax_range_text: n is nil')
  end

  if n > 10 then
    return nil
  end

  n = n + 1

  local syn_name, start_line, start_col, end_line, end_col = get_syntax_range(line, col)

  if not syn_name then
    return
  end

  if vim.list_contains({ 'markdownUrl', 'mkdInlineURL', 'mkdURL' }, syn_name) then
    return get_range_text(start_line, start_col, end_line, end_col)
  end

  if vim.list_contains({ 'mkdLink', 'markdownLinkText' }, syn_name) then
    return search_link_syntax(end_line, end_col + 3, n)
  end

  if vim.list_contains({ 'mkdDelimiter', 'markdownLinkDelimiter' }, syn_name) then
    return search_link_syntax(end_line, end_col + 1, n)
  end

  return nil
end

function M.link_on_cursor()
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  return search_link_syntax(line, col, 0)
end

function M.headings()
  -- { { level = 1, text = 'heading1' }, { level = 2, text = 'heading' } ... }

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local headings = {}
  for ln = 1, #lines do
    if is_heading(get_syntax_name(ln, 1)) then
      local line = lines[ln]
      local level = #line:match('^#+')
      local text = vim.trim(line:gsub('%[(.+)%]%(.+%)', ' %1 '):gsub(' +', ' '):gsub('# *', ''))
      table.insert(headings, {
        level = level,
        line = vim.trim(line:sub(level + 1)),
        text = text,
        line_number = ln,
      })
    end
  end

  return headings
end

function M.insert_text(text)
  local _, line, col, _ = unpack(vim.fn.getcurpos())
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_text(buf, line - 1, col - 1, line - 1, col - 1, { text })
end

return M
