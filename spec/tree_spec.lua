require 'luaspec'
require 'tree'

describe['A tree'] = function()
  -- TODO contexts

  before = function()
    tree = Tree:new()
    words = { 'biography', 'biographic', 'biographical', 'biographer', 'biped', '' }
    words2 = { 'biographical', 'biographic' }
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
end
