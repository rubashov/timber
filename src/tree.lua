-- A tree class.

require 'l-table'

Tree = { }

function Tree:new()
  local o = { tree = { } }
  self.__index = self
  setmetatable(o, self)

  return o
end

-- TODO: UTF-8!
function Tree:ingest(word)
  if type(word) == 'table' then
    for _, w in ipairs(word) do
      print('(0) Ingesting word ‘' .. w .. '’')
      self:ingest(w)
    end
  elseif type(word) == 'string' then
    print('(1) Ingesting word ‘' .. word .. '’')
    self.tree[word] = 0
  end
end

function Tree:size()
  print('Returning ' .. table.size(self))
  return table.size(self.tree)
end
