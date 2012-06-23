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
function Tree.insert(tree, word)
  if tree.tree then tree = tree.tree end

  local lg = word:len()
  if lg > 0 then
    local head, tail = word:sub(1, 1), word:sub(2, word:len())

    tree[head] = tree[head] or { }
    Tree.insert(tree[head], tail)
  else
    tree[0] = ''
  end
end

function Tree.ingest(tree, words)
  if type(words) == 'table' then
    for _, word in ipairs(words) do
      Tree.insert(tree, word)
    end
  elseif type(word) == 'string' then -- ‘words’ is a single word after all.
    Tree.insert(tree, words)
  end
end

function Tree.size(tree)
  if tree.tree then tree = tree.tree end

  local n = 0

  for head, tail in pairs(tree) do
    local s
    if head == 0 then
      s = 1
    else
      s = Tree.size(tail)
    end

    n = n + s
  end

  return n
end

function Tree.dump(tree, leader, words)
  if tree.tree then
    tree = tree.tree
    leader = ''
    words = { }
  end

  for head, tail in pairs(tree) do
    if head ~= 0 then
      Tree.dump(tail, leader .. head, words)
    else
      table.insert(words, leader)
    end
  end

  return words
end

function Tree.delete(tree, word)
  if tree.tree then tree = tree.tree end

  if word ~= '' then
    local head, tail = word:sub(1, 1), word:sub(2, word:len())
    local t = tree[head]
    if t then
      Tree.delete(t, tail)
    end
  else
    if tree[0] == '' then
      tree[0] = nil
    end
  end
end
