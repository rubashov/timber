require 'luaspec'
require 'tree'

describe['A tree'] = function()
  -- TODO contexts

  before = function()
    tree = Tree:new()
    words = { 'biography', 'biographic', 'biographical', 'biographer', 'biped', '' }
    words2 = { 'biographical', 'biographic' }
  end

  it['inserts and ingests one word'] = function()
    tree:insert(words[1])
    expect(tree:size()).should_be(1)
    tree:insert(words[2])
    expect(tree:size()).should_be(2)
  end

  it['ingests the words'] = function()
    tree:ingest(words)
    expect(tree:size()).should_be(6)
    table.print(tree.tree)
    dump = tree:dump()
    expect(table.size(dump)).should_be(6)
    table.print(dump)

    tree2 = Tree:new()
    tree2:ingest(words2)
    expect(tree2:size()).should_be(2)
  end

  it['dumps the words'] = function()
    tree:ingest(words)
    expect(table.size(tree:dump())).should_be(6)
  end

  it['removes one word'] = function()
    tree:ingest(words)
    tree:delete('biographic')
    expect(table.size(tree:dump())).should_be(5)
  end

  it['matches one word'] = function()
    tree:ingest({ 'bio' })
    for _, word in ipairs({ 'Albion', 'amphibious', 'biography', 'dubious', 'obobiost' }) do
      expect(tree:match(word)).should_be(true)
    end

    for _, word in ipairs({ 'oboist', 'bibliography', 'Fibonacci' }) do 
      expect(tree:match(word)).should_be(false)
    end
  end

  it['looks for matching patterns'] = function()
    tree:ingest({ 'am', 'phi', 'bio', 'boi', 'an' })
    local t = tree:matches('amphibious')

    expect(table.size(t)).should_be(3)
  end

  it['looks for more matching patterns'] = function()
    tree:ingest({ 'am', 'amphi', 'amphibious' })
    local t = tree:matches('amphibious')

    expect(table.size(t)).should_be(3)
  end
end
