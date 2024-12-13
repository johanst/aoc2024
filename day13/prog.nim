import strutils
import math
import sets
import tables
import algorithm
import re

type Pos = tuple[x, y: int]
type
  Data = object
    a, b, p: Pos

proc parseInput(ip: openArray[string]): Data =
  var d: Data
  let p = re"\d+"
  let aa = ip[0].findAll(p)
  let bb = ip[1].findAll(p)
  let pp = ip[2].findAll(p)
  d.a = (x: parseInt(aa[0]), y: parseInt(aa[1]))
  d.b = (x: parseInt(bb[0]), y: parseInt(bb[1]))
  d.p = (x: parseInt(pp[0]), y: parseInt(pp[1]))
  return d

proc getInput(fname: string): seq[Data] =
  var sd: seq[Data]
  var l: seq[string]
  for line in lines(fname):
    if line.len > 0:
      l.add(line.strip())
  assert l.len mod 3 == 0
  for idx in 0..<(l.len div 3):
    sd.add(parseInput(l[idx*3..<(idx+1)*3]))
  return sd

proc calcToken(d: Data): int =
  # let xmax = min(min(d.p.x div d.a.x, d.p.x div d.b.x), 100)
  # let ymax = min(min(d.p.y div d.a.y, d.p.y div d.b.y), 100)
  var cost = high(int)
  for na in 0..100:
    let xa = na * d.a.x
    let ya = na * d.a.y
    if xa > d.p.x or ya > d.p.y:
      break
    for nb in 0..100:
      let xb = nb * d.b.x
      let yb = nb * d.b.y
      let x = xa + xb
      let y = ya + yb
      if x > d.p.x or y > d.p.y:
        break
      if x == d.p.x and y == d.p.y:
        cost = min(3*na + nb, cost)
  if cost == high(int):
    cost = 0
  return cost

assert calcToken(getInput("ex0.txt")[0]) == 280

proc calcTokens(fname: string): int =
  let d = getInput(fname)
  for n, dd in d:
    result += calcToken(dd)

assert calcTokens("ex0.txt") == 480

proc part1(fname: string): int =
  return calcTokens(fname)

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
