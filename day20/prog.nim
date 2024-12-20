import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm
import heapqueue

type Pos = tuple[x, y: int]
type
  Data = object
    m: seq[string]
    s: Pos
    e: Pos
    xsz, ysz: int

type
  State = object
    cost: int
    x, y: int
    # xcs, ycs, xce, yce: int
    # dx, dy: int
    path: seq[Pos]

proc `<`(a, b: State): bool =
  a.cost < b.cost

proc getInput(fname: string): Data =
  var d: Data
  var yidx = 0
  for line in lines(fname):
    var l = line.strip()
    d.xsz = l.len()
    var xidx = l.find('S')
    if xidx != -1:
      d.s = (x: xidx, y: yidx)
      l[xidx] = '.'
    xidx = l.find('E')
    if xidx != -1:
      d.e = (x: xidx, y: yidx)
      l[xidx] = '.'
    yidx += 1
    d.m.add(l)
  d.ysz = d.m.len
  return d

proc getInitState(d: Data): State =
  var s: State
  s.x = d.s.x
  s.y = d.s.y
  s.path.add((x: s.x, y: s.y))
  return s

proc drawMap(d: Data, s: State) =
  for y, l in d.m:
    var ll = l
    if y == d.s.y:
      ll[d.s.x] = 'S'
    if y == d.e.y:
      ll[d.e.x] = 'E'
    if y == s.y:
      ll[s.x] = '@'
    echo ll

proc runSmallExample() =
  let d = getInput("ex0.txt")
  var s = getInitState(d)
  drawMap(d, s)

# runSmallExample()

proc umod(a, b: int): int =
  result = a mod b
  if result < 0:
    result += b

assert umod(-13, 11) == 9

proc getShortestPathFrom(d: Data, x0, y0: int): (seq[Pos], Table[Pos, int]) =
  var s0 = getInitState(d)
  if x0 != -1:
    s0.x = x0
    s0.y = y0
  var v: Table[Pos, int] # posx, posy, dx, dy -> cost
  var hq: HeapQueue[State]
  hq.push(s0)
  v[(s0.x, s0.y)] = 0
  while hq.len > 0:
    let s = hq.pop()
    if (s.x, s.y) == (d.e.x, d.e.y):
      var path: Table[Pos, int]
      for i in 0..<s.path.len:
        path[s.path[i]] = i
      return (s.path, path)
    let directions = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    for delta in directions:
      let (dx, dy) = (delta[0], delta[1])
      let p: Pos = (x: s.x + dx, y: s.y + dy)
      if d.m[p.y][p.x] == '#':
        continue
      let cost = s.cost + 1
      if v.contains(p) and cost >= v[p]:
        continue
      v[p] = cost
      var sn = State(cost: cost, x: p.x, y: p.y, path: s.path)
      sn.path.add((x: p.x, y: p.y))
      hq.push(sn)
  return (@[], initTable[Pos, int]())

proc getNumCheats(fname: string, minsave: int): int =
  let d = getInput(fname)
  var (path, psteps) = getShortestPathFrom(d, -1, -1)
  assert path.len == psteps.len
  let sp = psteps[(x: d.e.x, y: d.e.y)]
  assert sp == path.len - 1
  assert psteps[(x: d.s.x, y: d.s.y)] == 0
  # APPARENTLY ALL '.' are covered
  # for y in 0..<d.ysz:
  #   for x in 0..<d.xsz:
  #     let c = d.m[y][x]
  #     let p = (x: x, y: y)
  #     if c == '.' and p notin pcosts:
  #       echo x, " ", y
  for p in path:
    # var dbg = p == (x: 7, y: 7)
    let directions = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    for delta in directions:
      let p1 = (x: p.x + delta[0], y: p.y + delta[1])
      if d.m[p1.y][p1.x] != '#':
        continue
      for delta2 in directions:
        let p2 = (x: p1.x + delta2[0], y: p1.y + delta2[1])
        if p2 notin psteps:
          continue
        if psteps[p2] < psteps[p]:
          continue
        let cheat_steps = psteps[p] + 2 + (sp - psteps[p2])
        if sp - cheat_steps >= minsave:
          # echo "p=", p, " -> p2", p2
          result += 1

assert getNumCheats("ex0.txt", 38) == 3
assert getNumCheats("ex0.txt", 64) == 1

proc getNumCheats2(fname: string, minsave: int): int =
  let d = getInput(fname)
  var (path, psteps) = getShortestPathFrom(d, -1, -1)
  assert path.len == psteps.len
  let sp = psteps[(x: d.e.x, y: d.e.y)]
  assert sp == path.len - 1
  assert psteps[(x: d.s.x, y: d.s.y)] == 0
  for p in path:
    # var dbg = p == (x: 7, y: 7)
    for dy in -20..20:
      for dx in -20..20:
        if abs(dy) + abs(dx) > 20:
          continue
        let pp = (x: p.x + dx, y: p.y + dy)
        if not psteps.contains(pp):
          continue # it's a wall
        if psteps[pp] <= psteps[p]:
          continue
        let cheat_steps = psteps[p] + abs(dx) + abs(dy) + (sp - psteps[pp])
        if sp - cheat_steps >= minsave:
          # echo "p=", p, " -> p2", p2
          result += 1

assert getNumCheats2("ex0.txt", 74) == 7

proc part1(fname: string): int =
  return getNumCheats(fname, 100)

proc part2(fname: string): int =
  return getNumCheats2(fname, 100)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
