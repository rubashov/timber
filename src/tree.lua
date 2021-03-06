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

  Tree.do_insert(tree, word, { }, 0)
end

function Tree.do_insert(tree, word, hyph, n)
  local lg = word:len()
  if lg > 0 then
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
      if n > 0 and word:len() > 1 and word:sub(1, 1) == '.' then
        print("Error: read pattern with a dot inside a word") -- TODO raise some exception
        -- (Still proceeds for the moment).
      end

      tree[head] = tree[head] or { }
      Tree.do_insert(tree[head], tail, hyph, n + 1)
    end
  else
    tree[0] = hyph
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
    if head == 0 then
      if with_hyph then
        local word = leader
        local hyph = tail

        pattern = Tree.to_pattern(word, hyph)
        table.insert(words, pattern)
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

function Tree.to_pattern(word, hyph)
  local l = word:len()

  if hyph[0] then pattern = tostring(hyph[0]) else pattern = '' end
  for i = 1, l do
    pattern = pattern .. word:sub(i, i)
    if hyph[i] then
      pattern = pattern .. tostring(hyph[i])
    end
  end

  return pattern
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

function Tree.matches(tree, word, with_hyph)
  dotted_word = '.' .. word .. '.'
  matches = { }

  tree = tree.tree

  local l = dotted_word:len()
  while l > 0 do
    Tree.do_matches(tree, dotted_word, matches, '', with_hyph)
    _, dotted_word = dotted_word:chop()
    l = l - 1
  end

  return matches
end

function Tree.do_matches(tree, word, matches, start, with_hyph)
  if tree.tree then
    tree = tree.tree
  end
  if not matches then matches = { } end
  if not start then start = '' end

  if word ~= '' then
    local head, tail = word:chop()
    local t = tree[head]

    if t then
      Tree.do_matches(t, tail, matches, start ..  head, with_hyph)
    end
  end

  if tree[0] then
    if with_hyph then
      table.insert(matches, Tree.to_pattern(start, tree[0]))
    else
      table.insert(matches, start)
    end
  end

  return matches
end

function Tree.hyphenate(tree, word, show_hyph)
  dword = '.' .. word .. '.'
  hyph_points = { }
  tree = tree.tree
  local i, l = 0, dword:len()
  while i < l do
    Tree.do_hyphenate(tree, dword, hyph_points, i)
    _, dword = dword:chop()
    i = i + 1
  end

  local s = ''
  for i = 1, l - 2 do
    s = s .. word:sub(i, i)
    if hyph_points[i+1] and i < l - 2 then
      if show_hyph then
        s = s .. tostring(hyph_points[i+1])
      else
        if hyph_points[i+1] % 2 == 1 then
          s = s .. '-'
        end
      end
    end
  end

  return s
end

function Tree.do_hyphenate(tree, word, hyph_points, n)
  if tree.tree then
    tree = tree.tree
  end
  if not hyph_points then hyph_points = { } end

  if word ~= '' then
    local head, tail = word:chop()
    local t = tree[head]

    if t then
      Tree.do_hyphenate(t, tail, hyph_points, n)
    end
  end

  local hyph = tree[0]
  if hyph then
    for pos, val in pairs(hyph) do
      hyph_points[pos + n] = math.max(hyph_points[pos + n] or 0, val)
    end
  end
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
