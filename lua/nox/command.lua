local buffer = require('nox.buffer')

local M = {}

function M.ogp(format)
  if format == '' then
    format = 'a'
  end

  return buffer.replace_text(function(url)
    return vim.fn['nox#api#ogp_text'](format, url)
  end)
end

local function open(command, url)
  if #command == 1 then
    vim.fn.setreg(command, url)
  elseif command == 'external' then
    vim.fn['openbrowser#open'](url)
  else
    vim.cmd(command .. ' ' .. url)
  end
end

function M.open_link_on_cursor(open_command, fallback)
  local api = require('nox.api')

  local url = buffer.link_on_cursor()
  if not url then
    if fallback then
      fallback()
    end
    return
  end

  if not url:find('^@') then -- not '@foo/bar'
    open('external', url)
    return
  end

  if open_command == '' then
    open_command = 'edit'
  end

  local id = url:sub(2)
  if id:find('^[0-9a-zA-Z]+$') and #id == 26 then -- `@0123456789ABCDEFGHIJKLMNO`
    id = api.resolve_ulid(url:sub(2))
  end

  open(open_command, vim.fn['nox#id#to_url'](id))
end

return M
