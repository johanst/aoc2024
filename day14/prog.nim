import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm

type Pos = tuple[x, y: int]
type
  Data = object
    p, v: Pos

proc getInput(fname: string): seq[Data] =
  let p = re"-?\d+"
  var sd: seq[Data]
  for line in lines(fname):
    let nn = findAll(line.strip(), p)
    let nni = nn.mapIt(parseInt(it))
    let d = Data(
      p: (x: nni[0], y: nni[1]),
      v: (x: nni[2], y: nni[3]))
    sd.add(d)
  return sd

proc umod(a, b: int): int =
  result = a mod b
  if result < 0:
    result += b

assert umod(-13, 11) == 9

proc getQuadrant(p: Pos, xsz, ysz: int): int =
  let mx = xsz div 2
  let my = ysz div 2
  if p.x == mx or p.y == my:
    return 0
  elif p.x < mx:
    if p.y < my:
      return 1
    elif p.y > my:
      return 2
    else:
      assert false
  elif p.x > mx:
    if p.y < my:
      return 3
    elif p.y > my:
      return 4
    else:
      assert false
  else:
    assert false

proc getSafetyFactor(fname: string, xsz, ysz: int): int =
  let sd = getInput(fname)
  var qt: Table[int, int]
  for i, d in sd:
    let x = umod((d.p.x + d.v.x * 100), xsz)
    let y = umod((d.p.y + d.v.y * 100), ysz)
    let q = getQuadrant((x: x, y: y), xsz = xsz, ysz = ysz)
    if q == 0:
      continue
    if qt.contains(q):
      qt[q] += 1
    else:
      qt[q] = 1
  result = 1
  for _, cnt in qt:
    result *= cnt

assert getSafetyFactor("ex0.txt", xsz = 11, ysz = 7) == 12

proc displayRobots(sd: seq[Data], sec: int) =
  let xsz = 101
  let ysz = 103
  var m: HashSet[Pos]
  for d in sd:
    let x = umod((d.p.x + d.v.x * sec), xsz)
    let y = umod((d.p.y + d.v.y * sec), ysz)
    m.incl((x: x, y: y))
  for y in 0..<ysz:
    var l: string
    for x in 0..<xsz:
      if (x: x, y: y) in m:
        l.add("X")
      else:
        l.add(".")
    echo l

proc fumbleAfterSolutionToPart2() =
  let xsz = 101
  let ysz = 103
  let sd = getInput("input.txt")
  for i in 0..8006: # after visual inspection
    var hy: Table[int, seq[int]]
    for d in sd:
      let x = umod((d.p.x + d.v.x * i), xsz)
      let y = umod((d.p.y + d.v.y * i), ysz)
      if y in hy:
        hy[y].add(x)
      else:
        hy[y] = @[x]
    var cnt10tot = 0
    for y, sx in hy:
      if sx.len < 10:
        continue
      var ssx = sx
      sort(ssx)

      var lastx = ssx[0]
      var cnt10 = 0
      for x in ssx:
        if lastx + 1 == x or lastx == x:
          cnt10 += 1
        else:
          cnt10 = 0
        if cnt10 == 10:
          cnt10tot += 1
          break
        lastx = x
    if cnt10tot > 10:
      echo i, "-------------------------- "
      displayRobots(sd, i)


proc part1(fname: string): int =
  return getSafetyFactor("input.txt", xsz = 101, ysz = 103)

proc part2(fname: string): int =
  fumbleAfterSolutionToPart2()
  return 8006 # after visual inspection

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
