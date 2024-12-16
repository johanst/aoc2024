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

type
  State = object
    cost: int
    x, y: int
    dx, dy: int
    path: seq[Pos]

proc `<`(a, b: State): bool =
  a.cost < b.cost

proc getInput(fname: string): Data =
  var d: Data
  var yidx = 0
  for line in lines(fname):
    var l = line.strip()
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
  return d

proc getInitState(d: Data): State =
  var s: State
  s.x = d.s.x
  s.y = d.s.y
  s.dx = 1
  s.dy = 0
  s.path.add((x: s.x, y: s.x))
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

proc getMinCost(fname: string): int =
  let d = getInput(fname)
  let s0 = getInitState(d)
  var v: Table[(Pos, Pos), int] # posx, posy, dx, dy -> cost
  var hq: HeapQueue[State]
  hq.push(s0)
  v[((s0.x, s0.y), (s0.dx, s0.dy))] = 0
  while hq.len > 0:
    let s = hq.pop()
    if (s.x, s.y) == (d.e.x, d.e.y):
      return s.cost
    let dir = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    var dirIdx = 0
    while (s.dx, s.dy) != dir[dirIdx]:
      dirIdx += 1
    for i in -1..1:
      var cost = 1001 # turn + forward
      if i == 0:
        cost = 1 # just forward
      cost += s.cost
      let dirn = dir[umod(dirIdx + i, 4)]
      let p = (x: s.x + dirn[0], y: s.y + dirn[1])
      if d.m[p.y][p.x] == '#':
        continue
      let vv = (p, (dirn[0], dirn[1]))
      if v.contains(vv):
        if cost > v[vv]:
          continue
      v[vv] = cost
      let sn = State(cost: cost, x: p.x, y: p.y, dx: dirn[0], dy: dirn[1])
      hq.push(sn)
  return 0

assert getMinCost("ex0.txt") == 7036

proc getNumSeats(fname: string): int =
  let shortest_path = getMinCost(fname)
  let d = getInput(fname)
  var seats: HashSet[Pos]
  let s0 = getInitState(d)
  var v: Table[(Pos, Pos), int] # posx, posy, dx, dy -> cost
  var hq: HeapQueue[State]
  hq.push(s0)
  v[((s0.x, s0.y), (s0.dx, s0.dy))] = 0
  while hq.len > 0:
    let s = hq.pop()
    if (s.x, s.y) == (d.e.x, d.e.y):
      for seat in s.path:
        seats.incl(seat)
      continue # there may be more
    let dir = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    var dirIdx = 0
    while (s.dx, s.dy) != dir[dirIdx]:
      dirIdx += 1
    for i in -1..1:
      var cost = 1001 # turn + forward
      if i == 0:
        cost = 1 # just forward
      cost += s.cost
      if cost > shortest_path:
        continue
      let dirn = dir[umod(dirIdx + i, 4)]
      let p = (x: s.x + dirn[0], y: s.y + dirn[1])
      if d.m[p.y][p.x] == '#':
        continue
      let vv = (p, (dirn[0], dirn[1]))
      if v.contains(vv):
        if cost > v[vv]:
          continue
      v[vv] = cost
      var sn = State(cost: cost, x: p.x, y: p.y, dx: dirn[0], dy: dirn[1], path: s.path)
      sn.path.add((x: p.x, y: p.y))
      hq.push(sn)
  return seats.len

assert getNumSeats("ex0.txt") == 45

proc part1(fname: string): int =
  return getMinCost("input.txt")

proc part2(fname: string): int =
  return getNumSeats("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
