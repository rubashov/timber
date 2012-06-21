function table.size(t)
  local n = 0

  for _ in pairs(t) do
    n = n + 1
  end

  return n
end

function table.print(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    for i = 1, indent do io.write('  ') end
    print(k)
    if type(v) == 'table' then
      table.print(v, indent + 1)
    else
      for i = 1, indent do io.write('  ') end
      print(tostring(v))
    end
  end
end
