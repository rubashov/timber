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
      self:ingest(w)
    end
  elseif type(word) == 'string' then
    self.tree[word] = 0
  end
end

function Tree:size()
  return table.size(self.tree)
end
