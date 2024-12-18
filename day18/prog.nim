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
    m: seq[Pos]
    e: Pos
    c: HashSet[Pos]

type
  State = object
    cost: int
    x, y: int

proc `<`(a, b: State): bool =
  a.cost < b.cost

proc getInput(fname: string, e: Pos, n: int): Data =
  var d: Data
  let r = re"\d+"
  for line in lines(fname):
    let p = line.findAll(r)
    d.m.add((x: parseInt(p[0]), y: parseInt(p[1])))
  for i in 0..<n:
    d.c.incl(d.m[i])
  d.e = e
  return d

proc getShortestPath(fname: string, e: Pos, n: int): int =
  let d = getInput(fname, e, n)
  var s0: State
  var v: Table[Pos, int] # posx, posy, dx, dy -> cost
  var hq: HeapQueue[State]
  hq.push(s0)
  v[(s0.x, s0.y)] = 0
  while hq.len > 0:
    let s = hq.pop()
    if (s.x, s.y) == (d.e.x, d.e.y):
      return s.cost
    let directions = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    for delta in directions:
      let (dx, dy) = (delta[0], delta[1])
      let p: Pos = (x: s.x + dx, y: s.y + dy)
      if s.x < 0 or s.x > d.e.x or s.y < 0 or s.y > d.e.y:
        continue
      if d.c.contains(p):
        continue
      let cost = s.cost + 1
      if v.contains(p) and cost >= v[p]:
        continue
      v[p] = cost
      let sn = State(cost: cost, x: p.x, y: p.y)
      hq.push(sn)
  return 0

assert getShortestPath("ex0.txt", (x: 6, y: 6), 12) == 22

proc getFirstBlocker(fname: string, e: Pos, n0: int): Pos =
  let d = getInput(fname, e, n0)
  var count = n0
  while getShortestPath(fname, e, count) != 0:
    echo count
    count += 1
  return d.m[count - 1]

assert getFirstBlocker("ex0.txt", (x: 6, y: 6), 12) == (x: 6, y: 1)

proc part1(fname: string): int =
  return getShortestPath("input.txt", (x: 70, y: 70), 1024)

proc part2(fname: string): Pos =
  return getFirstBlocker("input.txt", (x: 70, y: 70), 1024)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
