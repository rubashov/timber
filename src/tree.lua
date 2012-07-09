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
function Tree.insert(tree, word, hyph, n)
  if tree.tree then tree = tree.tree end
  if not hyph then hyph = { } end
  if not n then n = 0 end

  local lg = word:len()
  if lg > 0 then
    local num = ''
    local head, tail = word:sub(1, 1), word:sub(2, word:len())
    -- TODO lpeg!
    while head >= '0' and head <= '9' do
      word = tail
      head, tail = word:sub(1, 1), word:sub(2, word:len())
      num = num .. head
    end

    if num ~= '' then
      hyph[n] = tonumber(num)
    end

    tree[head] = tree[head] or { }
    Tree.insert(tree[head], tail, hyph, n + 1)
  else
    tree[0] = hyph
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
    if tree[0] then
      tree[0] = nil
    end
  end
end

function string.chop(str)
  return str:sub(1, 1), str:sub(2, str:len())
end

function Tree.match(tree, word)
  return table.size(Tree.matches(tree, word)) > 0
end

function Tree.matches(tree, word)
  matches = { }

  local l = word:len()
  while l > 0 do
    Tree.do_matches(tree, word, matches)
    _, word = word:chop()
    l = l - 1
  end

  return matches
end

function Tree.do_matches(tree, word, matches, start)
  if tree.tree then
    tree = tree.tree
    tree.root = tree
  end
  if not matches then matches = { } end
  if not start then start = '' end
  if not n then n = 0 end
  -- print(word, start)
  -- print("Matching " .. word .. ", start = " .. start .. ", " ..  table.size(matches) .. " so far.")

  if word ~= '' then
    local head, tail = word:chop()
    local t = tree[head]
    -- Tree.matches(tree.root, tail, matches, '')
    if t then
      t.root = tree.root
      Tree.do_matches(t, tail, matches, start ..  head)
    end
  end

  if tree[0] then
    -- TODO Figure out what’s happening
    if matches[start] then
      matches[start] = matches[start] + 1
    else
      matches[start] = 0
    end

    print(word, start, matches[start])
  end

  return matches
end

function table.is_equal(t1, t2)
  local t1c, t2c = { }, { }

  -- Shallow copy
  -- TODO Implement deep one.
  for k1, v1 in pairs(t1) do
    t1c[k1] = v1
  end

  for k2, v2 in pairs(t2) do
    t2c[k2] = v2
  end

  table.sort(t1c)
  table.sort(t2c)

  if table.size(t1c) ~= table.size(t2c) then
    return false
  end

  for k1, v1 in pairs(t1c) do
    if t2c[k1] ~= v1 then
      return false
    end
  end

  return true
end
