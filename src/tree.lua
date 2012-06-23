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
  else
    tree[0] = ''
  end
end

-- TODO: UTF-8!
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
    local s
    if head == 0 then
      s = 1
    else
      s = Tree.tree_size(tail)
    end

    n = n + s
  end

  return n
end

function Tree:size()
  return Tree.tree_size(self.tree)
end

function Tree.tree_dump(leader, tree, words)
  for head, tail in pairs(tree) do
    if head ~= 0 then
      Tree.tree_dump(leader .. head, tail, words)
    else
      table.insert(words, leader)
    end
  end
end

function Tree:dump()
  words = { }
  Tree.tree_dump('', self.tree, words)
  return words
end

function Tree.tree_delete(tree, word)
  if word ~= '' then
    local head, tail = word:sub(1, 1), word:sub(2, word:len())
    local t = tree[head]
    if t then
      Tree.tree_delete(t, tail)
    end
  else
    if tree[0] == '' then
      tree[0] = nil
    end
  end
end

function Tree:delete(word)
  Tree.tree_delete(self.tree, word)
end
