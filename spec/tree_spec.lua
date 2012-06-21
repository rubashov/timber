require 'luaspec'
require 'tree'

describe['A tree'] = function()
  before = function()
    tree = Tree:new()
    words = { 'biography', 'biographic', 'biographical', 'biographer', 'biped', '' }
  end

  it['ingests the words'] = function()
    tree:ingest(words)
    expect(table.size(tree.tree)).should_be(1)
    expect(tree:size()).should_be(5)
    table.print(tree.tree)
  end
end
