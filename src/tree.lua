-- A tree class.

require 'l-table'

Tree = { }

function Tree:new()
  local o = { tree = { } }
  self.__index = self
  setmetatable(o, self)

  return o
end

function Tree.ingest_string(tree, word)
  local lg = word:len()
  if lg > 0 then
    local head, tail = word:sub(1, 1), word:sub(2, word:len())

    tree[head] = tree[head] or { }
    Tree.ingest_string(tree[head], tail)
  end
end

-- TODO: UTF-8!
-- TODO: prefixes
function Tree:ingest(word)
  if type(word) == 'table' then
    for _, w in ipairs(word) do
      self:ingest(w)
    end
  elseif type(word) == 'string' then
    Tree.ingest_string(self.tree, word)
  end
end

function Tree.tree_size(tree)
  local n = 0

  for head, tail in pairs(tree) do
    if head == 'h' then print('Size: ' .. table.size(tail)) end
    local s
    if table.size(tail) == 0 then
      print'a'
      s = 1
    else
      print'b'
      s = Tree.tree_size(tail)
    end

    n = n + s
  end

  return n
end

function Tree:size()
  return Tree.tree_size(self.tree)
end
