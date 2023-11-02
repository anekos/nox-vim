local buffer = require('nox.buffer')

local M = {}

function M.ogp(format)
  if format == '' then
    format = 'a'
  end

  return buffer.replace_text(function (url)
    return vim.fn['nox#api#ogp_text'](format, url)
  end)
end

return M
