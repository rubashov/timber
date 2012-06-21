require 'lpeg'
require 'tree'

local P, C = lpeg.P, lpeg.C
local semlicolon = P';'
local field = (1 - semlicolon)^1
local linepatt = C(field) * semlicolon

tree = Tree:new()
for line in io.lines(arg[1]) do
  local word = lpeg.match(linepatt, line)
  tree:ingest(word)
  print('Ingested ' .. word)
end
