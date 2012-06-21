require 'luaspec'
require 'tree'

describe['A tree'] = function()
  before = function()
    tree = Tree:new()
    words = { 'biography', 'biographic', 'biographical', 'biographer', 'biped' }
  end

  it['ingests the words'] = function()
    tree:ingest(words)
    print('Size of tree is ' .. tree:size())
    expect(tree:size()).should_be(5)
  end
end
