import strutils
import math
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

proc calcToken(d: Data, offset: int): int =
  let px = d.p.x + offset
  let py = d.p.y + offset
  let na = (px * d.b.y - py * d.b.x) div (d.a.x * d.b.y - d.a.y * d.b.x)
  let nb = (px - d.a.x * na) div d.b.x
  if na * d.a.x + nb * d.b.x == px and na * d.a.y + nb * d.b.y == py:
    result = na * 3 + nb

proc calcTokens(fname: string): int =
  let d = getInput(fname)
  for n, dd in d:
    result += calcToken(dd, 0)

assert calcTokens("ex0.txt") == 480

proc calcTokens2(fname: string): int =
  let d = getInput(fname)
  for n, dd in d:
    result += calcToken(dd, 10000000000000)

proc part1(fname: string): int =
  return calcTokens(fname)

proc part2(fname: string): int =
  return calcTokens2(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
