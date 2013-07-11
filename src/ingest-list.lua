lpeg = lpeg or require 'lpeg'
require 'tree'

local P, C = lpeg.P, lpeg.C
local semicolon = P';'
local field = (1 - semicolon)^1
local linepatt = C(field) * semicolon

tree = Tree:new()

function ingest(filename, format, silent)
  local n = 0
  for line in io.lines(filename) do
    local word
    if format == 1 then
      word = lpeg.match(linepatt, line)
    else -- default, format 0
      word = line
    end
    if word then
      tree:ingest(word)
      if not silent then
        print('Ingested ' .. word)
      end
      n = n + 1
    end
  end

  print('Ingested ' .. tostring(n) .. ' words')
end

function main(arg)
  if arg[1] == '-q' then
    silent = true
    path = arg[2]
  else
    path = arg[1]
  end

  ingest(path, 1, silent)
end

main(arg)
