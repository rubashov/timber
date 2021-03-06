require 'luaspec'
require 'tree'

describe['A tree'] = function()
  -- TODO contexts
  -- TODO Don’t overwrite entry in the spec table!

  before = function()
    tree = Tree:new()
    words = { 'biography', 'biographic', 'biographical', 'biographer', 'biped', '' }
    words2 = { 'biographical', 'biographic' }
    patterns = { 'biog3raph1er', 'bio1g2raph1ic', 'bio1g2raph1ic1al', 'biog11raphy' }
    patterns_with_dots = { '.ab1a', '.ab3l', '.abo2', '.ab3ol', '.ab1or', 'ab4ol.' }

  end

  it['inserts and ingests one word'] = function()
    tree:insert(words[1])
    expect(tree:size()).should_be(1)
    tree:ingest(words[2])
    expect(tree:size()).should_be(2)
  end

  it['ingests the plain words'] = function()
    tree:ingest(words)
    expect(tree:size()).should_be(6)
    dump = tree:dump()
    expect(table.size(dump)).should_be(6)

    tree2 = Tree:new()
    tree2:ingest(words2)
    expect(tree2:size()).should_be(2)

    -- Alternative syntax
    tree3 = Tree:new()
    tree3:ingest('biography', 'biographic', 'biographical', 'biographer', 'biped', '')
    expect(tree3:size()).should_be(6)
  end

  it['ingests the words with hyphenation values, and re-reads them'] = function()
    tree:ingest(patterns)
    expect(tree:size()).should_be(4)
    local words = tree:dump(tree)
    local words_should_be = { 'biographer', 'biographic', 'biographical', 'biography' }
    expect(table.is_equal(words, words_should_be)).should_be(true)

    local dumped_patterns = tree:dump_patterns(tree)
    expect(table.is_equal(patterns, dumped_patterns)).should_be(true)
  end

  it ['ingests words with hyphenation values and dots, and dumps them back'] = function()
    tree:ingest(patterns_with_dots)
    expect(tree:size()).should_be(6)
    local dumped_patterns = tree:dump_patterns(tree)
    expect(table.is_equal(patterns_with_dots, dumped_patterns)).should_be(true)
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

  it['matches using patterns with dots'] = function()
    tree:ingest(patterns_with_dots)
    -- { '.ab1a', '.ab3l', '.abo2', '.ab3ol', '.ab1or', 'ab4ol.' }
    local t = tree:matches('abol')

    expect(table.size(t)).should_be(3)

    expect(table.is_equal(t, { '.abo', '.abol', 'abol.' })).should_be(true)
  end

  it['inserts patterns with dots correctly'] = function()
    tree:ingest('a1ic', 'l1g2', 'e1b', 'br4', 'e2br', '2ai2', 'eb1ra')
    tree:insert('4ai.')
    expect(table.is_equal(tree:matches('algebraic'), { 'lg', 'ebra', 'ebr', 'eb', 'br', 'aic', 'ai' })).should_be(true)
    expect(table.is_equal(tree:matches('Dai'), { 'ai', 'ai.' })).should_be(true)
  end

  it['returns patterns with hyphenation points when asked'] = function()
    tree:ingest('a1ic', 'l1g2', 'e1b', 'br4', 'e2br', '2ai2', 'eb1ra', '4ai.')
    expect(table.is_equal(tree:matches('algebraic', true), { 'l1g2', 'e1b', 'e2br', 'eb1ra', 'br4', '2ai2', 'a1ic' })).should_be(true)
  end

  it['hyphenates'] = function()
    tree:ingest('io2gr', '1gr', '3raphy', 'bi3ogr', '1phy', '4graphy', '2io', 'ph1ic', 'io2gr', '1ca', '5graphic', '4aphi')
    expect(tree:hyphenate("biography")).should_be("bi-og-ra-phy")
    expect(tree:hyphenate("biographical")).should_be("bi-o-graph-i-cal")
  end

  it['hyphenates without leaving a leading hyphen'] = function()
    tree:ingest('1ka', 'a1p', 'p3se', '2p1s', '1se', '2eln', 'lnd2', '4ln', '2n1d', '1de', 'e1m')
    expect(tree:hyphenate("kapselndem")).should_be("kap-seln-de-m") -- Not -kap-seln-de-m
  end

  it['hyphenates without leaving a trailing hyphen'] = function()
    tree:ingest('4r1b', 'e2it', '4t3n2', '3nehm', '1ne', '2ehm', '2h1m', '1me', 'rb2u', '4r1b', 'bunde4s', 'un1', '2n1d', 'd2es.', 'des1', '1de')
    expect(tree:hyphenate("Arbeitnehmerbundes")).should_be("Ar-beit-neh-mer-bun-des") -- not Ar-beit-neh-mer-bun-des-
  end

  it['shows the hyphenation values'] = function()
    tree:ingest('4r1b', 'e2it', '4t3n2', '3nehm', '1ne', '2ehm', '2h1m', '1me', 'rb2u', '4r1b', 'bunde4s', 'un1', '2n1d', 'd2es.', 'des1', '1de')
    expect(tree:hyphenate("Arbeitnehmerbundes", true)).should_be("A4r1be2i4t3n2e2h1me4r1b2u2n1d2e4s")
  end
end
