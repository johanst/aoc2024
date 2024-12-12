import strutils
import math
import sets
import tables
import algorithm

type Pos = tuple[x, y: int]
type
  Data = object
    m: seq[string]
    xsz, ysz: int

type
  State = object
    v: seq[seq[bool]]

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    let l = line.strip()
    d.m.add(l)
    d.xsz = l.len
  d.ysz = d.m.len
  return d

proc numSides(sides: Table[int, seq[int]]): int =
  # echo sides
  for _, s in sides:
    var ss = s
    ss.sort()
    var last = ss[0] - 1
    result += 1
    for n in ss:
      if n != last + 1:
        result += 1
      last = n

proc calcSides(sides: Table[Pos, seq[Pos]]): int =
  # for dir, side in sides:
  #   echo dir, ": ", side

  var left: Table[int, seq[int]]
  for _, (x, y) in sides[(-1, 0)]:
    if left.contains(x):
      left[x].add(y)
    else:
      left[x] = @[y]
  var ns = numSides(left)
  # echo ns
  result += ns

  var right: Table[int, seq[int]]
  for _, (x, y) in sides[(1, 0)]:
    if right.contains(x):
      right[x].add(y)
    else:
      right[x] = @[y]
  ns = numSides(right)
  # echo ns
  result += ns

  var up: Table[int, seq[int]]
  for _, (x, y) in sides[(0, -1)]:
    if up.contains(y):
      up[y].add(x)
    else:
      up[y] = @[x]
  ns = numSides(up)
  # echo ns
  result += ns

  var down: Table[int, seq[int]]
  for _, (x, y) in sides[(0, 1)]:
    if down.contains(y):
      down[y].add(x)
    else:
      down[y] = @[x]
  ns = numSides(down)
  # echo ns
  result += ns

proc getRegionSize(d: Data, s: var State, r, c: int): (int, int, int) =
  # echo "---> ", d.m[r][c]
  var area, perimeter: int
  var sides: Table[Pos, seq[Pos]]
  var paths = initHashSet[Pos]()
  var v = initHashSet[Pos]()
  paths.incl((x: c, y: r))
  while paths.len != 0:
    let p = paths.pop()
    v.incl(p)
    s.v[p.y][p.x] = true
    area += 1
    let dir = [(-1, 0), (0, 1), (1, 0), (0, -1)]
    for pp in dir:
      let y = pp[1] + p.y
      let x = pp[0] + p.x
      if y < 0 or y >= d.ysz or x < 0 or x >= d.xsz:
        if sides.contains(pp):
          sides[pp].add(p)
        else:
          sides[pp] = @[p]
        perimeter += 1
        continue
      if d.m[y][x] == d.m[r][c] and not v.contains((x: x, y: y)):
        paths.incl((x: x, y: y))
      elif d.m[y][x] != d.m[r][c]:
        if sides.contains(pp):
          sides[pp].add(p)
        else:
          sides[pp] = @[p]
        perimeter += 1
  # echo "area=", area, " perimeter=", perimeter
  let nsides = calcSides(sides)
  return (area, perimeter, nsides)

proc getScore(fname: string): int =
  let d = getInput(fname)
  var s: State
  for _ in 0..<d.ysz:
    s.v.add(newSeq[bool](d.xsz))
  for r in 0..<d.ysz:
    for c in 0..<d.xsz:
      if not s.v[r][c]:
        let (area, perimeter, _) = getRegionSize(d, s, r, c)
        result += area * perimeter

assert getScore("ex0.txt") == 1930

proc getScore2(fname: string): int =
  let d = getInput(fname)
  var s: State
  for _ in 0..<d.ysz:
    s.v.add(newSeq[bool](d.xsz))
  for r in 0..<d.ysz:
    for c in 0..<d.xsz:
      if not s.v[r][c]:
        let (area, _, sides) = getRegionSize(d, s, r, c)
        result += area * sides

echo getScore2("ex0.txt")
assert getScore2("ex0.txt") == 1206

proc part1(fname: string): int =
  return getScore(fname)

proc part2(fname: string): int =
  return getScore2(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
