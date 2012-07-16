-- A tree class.

require 'l-table'

Tree = { }

function string.chop(str)
  return str:sub(1, 1), str:sub(2, str:len())
end

function Tree:new()
  local o = { tree = { } }
  self.__index = self
  setmetatable(o, self)

  return o
end

-- TODO: UTF-8!
-- Assumes dots only come at the very beginning or the very end of patterns.
function Tree.insert(tree, word)
  if tree.tree then tree = tree.tree end
  local head, tail = word:chop()
  if head == '.' then
    tree['.'] = tree['.'] or { }
    tree = tree['.']
    word = tail
  end

  Tree.do_insert(tree, word, { }, 0)
end

function Tree.do_insert(tree, word, hyph, n)
  local lg = word:len()
  if lg > 0 and word:sub(1, 1) ~= '.' then
    local num = ''
    local head, tail = word:chop()
    -- TODO lpeg!
    while head >= '0' and head <= '9' do
      word = tail
      num = num .. head
      head, tail = word:chop()
    end

    if num ~= '' then
      hyph[n] = tonumber(num)
    end

    if head == '' then -- the rest of the word may have been consumed by the number
      tree[0] = hyph
    else
      tree[head] = tree[head] or { }
      Tree.do_insert(tree[head], tail, hyph, n + 1)
    end
  else
    if lg == 0 then
      tree[0] = hyph
    elseif lg == 1 then
      tree['.'] = hyph
    else
      print("Error: read pattern with a dot inside a word") -- TODO raise some exception
      -- (Still proceeds for the moment).
    end
  end
end

function Tree.ingest(tree, word, ...)
  if type(word) == 'table' then -- ‘word’ is actually a list of words.
    for _, w in ipairs(word) do
      Tree.insert(tree, w)
    end
  elseif type(word) == 'string' then
    Tree.insert(tree, word)
  end

  local n = select('#', ...)
  for i = 1, n do
    local w = select(i, ...)
    if type(w) == 'string' then
      Tree.insert(tree, w)
    end -- TODO Otherwise raise some kind of exception?
  end
end

-- Assumes dots only comes at the very beginning or the very end of patterns.
function Tree.size(tree)
  if tree.tree then tree = tree.tree end

   local size = Tree.do_size(tree) 
   local tree_dot = tree['.']
   if tree_dot then -- the initial dot is counted as a fake leaf in that case
     return size + Tree.do_size(tree_dot) - 1
   else
     return size
   end
end

function Tree.do_size(tree)
  local n = 0

  for head, tail in pairs(tree) do
    local s
    if head == 0 or head == '.' then
      s = 1
    else
      s = Tree.do_size(tail)
    end

    n = n + s
  end

  return n
end

function Tree.dump(tree, leader, words, with_hyph)
  if tree.tree then
    tree = tree.tree
    leader = ''
    words = { }
  end

  for head, tail in pairs(tree) do
    if head == 0 or (head == '.' and leader ~= '') then -- FIXME not ideal
      if head == '.' then leader = leader .. '.' end

      if with_hyph then
        if leader:sub(1, 1) == '.' then dot = '.' else dot = '' end
        local word = string.gsub(leader, '^%.', '')
        local hyph = tail

        local l = word:len()
        if hyph[0] then s = dot + tostring(hyph[0]) else s = dot end
        for i = 1, l do
          s = s .. word:sub(i, i)
          if hyph[i] then
            s = s .. tostring(hyph[i])
          end
        end

        table.insert(words, s)
      else
        table.insert(words, leader)
      end
    elseif type(head) == 'string' and head:len() == 1 then
      Tree.dump(tail, leader .. head, words, with_hyph)
    end
  end

  return words
end

function Tree.dump_patterns(tree)
  return Tree.dump(tree, '', { }, true)
end

-- FIXME for anchored (“dotted” patterns)
function Tree.delete(tree, word)
  if tree.tree then tree = tree.tree end

  if word ~= '' then
    local head, tail = word:chop()
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

function Tree.match(tree, word)
  return table.size(Tree.matches(tree, word)) > 0
end

function Tree.matches(tree, word)
  matches = { }

  tree = tree.tree
  if tree['.'] then Tree.do_matches(tree['.'], word, matches, '.') end

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
  end
  if not matches then matches = { } end
  if not start then start = '' end

  if word ~= '' then
    local head, tail = word:chop()
    local t = tree[head]

    if t then
      Tree.do_matches(t, tail, matches, start ..  head)
    end
  end

  -- FIXME This doesn’t return the actual pattern!  Bloody useless.
  if tree[0] or (tree['.'] and word == '') then
    if tree['.'] then start = start .. '.' end

    table.insert(matches, start)
  end

  return matches
end

function table.is_equal(t1, t2)
  if table.size(t1) ~= table.size(t2) then
    return false
  end

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

  for k1, v1 in pairs(t1c) do
    if t2c[k1] ~= v1 then
      return false
    end
  end

  return true
end
