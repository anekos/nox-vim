local api = require('nox.api')
local buffer = require('nox.buffer')

local M = {}

local function urlencode(url)
  local function hex(c)
    return string.format('%%%02X', string.byte(c))
  end
  url = url:gsub('([^%w ])', hex)
  url = url:gsub(' ', '+')
  return url
end

function M.attach_file(filepath)
  local ulid = vim.fn['nox#buffer#get_attribute']('ulid')
  local id = vim.fn['nox#buffer#document_id']()
  filepath = vim.fn.fnamemodify(filepath, ':p')
  vim.fn['nox#api#attach_file'](id, filepath)
  local name = vim.fn.fnamemodify(filepath, ':t')
  local link = '&' .. urlencode(name) .. '@' .. urlencode(ulid or id)
  buffer.insert_text('[' .. name .. '](' .. link .. ')')
end

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

function M.back_references()
  local ulid = vim.fn['nox#buffer#get_attribute']('ulid')
  local query

  if ulid == vim.NIL then
    local id = vim.fn['nox#buffer#document_id']()
    query = '&@"' .. id .. '"'
  else
    query = '&@' .. ulid
  end

  require('telescope._extensions.nox.picker.search').picker { query = query }
end

function M.meta()
  local id = vim.fn['nox#buffer#document_id']()
  assert(id ~= vim.NIL)
  vim.print(api.meta(id))
end

function M.open_link_on_cursor(open_command, fallback)
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
