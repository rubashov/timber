-- A tree class.

require 'l-table'

Tree = { }

Tree.INITIAL = 'INITIAL'
Tree.PROCESSING = 'PROCESSING'

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
    if head == 0 then
      table.insert(words, leader)
    elseif type(head) == 'string' and head:len() == 1 then
      Tree.dump(tail, leader .. head, words)
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

function string.chop(str)
  return str:sub(1, 1), str:sub(2, str:len())
end

function Tree.match(tree, word)
  if table.size(Tree.matches(tree, word)) > 0 then
    return true
  else
    return false
  end
end

function Tree.matches(tree, word, state, matches, start)
  if tree.tree then
    tree = tree.tree
    tree.root = tree
  end
  if not state then state = Tree.INITIAL end
  if not matches then matches = { } end
  if not start then start = '' end
  if not n then n = 0 end

  if word ~= '' then
    local head, tail = word:chop()
    local t = tree[head]
    Tree.matches(tree.root, tail, Tree.INITIAL, matches, '')
    if t then
      t.root = tree.root
      Tree.matches(t, tail, Tree.PROCESSING, matches, start ..  head)
    else
      if state == Tree.PROCESSING then
        if tree[0] == '' then
          -- TODO Figure out what’s happening
          matches[start] = true
        end
      end
    end
  end

  return matches
end
