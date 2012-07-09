require 'luaspec'
require 'tree'

describe['A tree'] = function()
  -- TODO contexts
  -- TODO Don’t overwrite entry in the spec table!

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

    -- Alternative syntax
    tree3 = Tree:new()
    tree3:ingest('biography', 'biographic', 'biographical', 'biographer', 'biped', '')
    print'----------------------'
    print(tree3:size())
    print'----------------------'
    expect(tree3:size()).should_be(6)
  end

  it['ingests the words'] = function()
    tree:ingest({ 'biog3raph1er', 'bio1g2raph1ic', 'bio1g2raph1ic1al', 'biog11raphy' })
    expect(tree:size()).should_be(4)
    local words = tree:dump(tree)
    local words_should_be = { 'biographer', 'biographic', 'biographical', 'biography' }
    expect(table.is_equal(words, words_should_be)).should_be(true)
  end

  it['ingests one word'] = function()
    tree:ingest('biographer')
    expect(tree:size()).should_be(1)
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
