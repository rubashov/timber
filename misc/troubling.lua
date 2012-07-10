t = { 1, 2, [4] = 4 }
print(#t) -- 2
v = { 1, 2, [4] = 4, [5] = 5 }
print(#v) -- 2
z = { [0] = 0, 1, 2, [4] = 4, [5] = 5 }
print(#z) -- 2
v[0] = 0
print(#v) -- 5
v[2] = nil
print(#v) -- 5
v[1] = nil
print(#v) -- 5
v[0] = nil
print(#v) -- 5
