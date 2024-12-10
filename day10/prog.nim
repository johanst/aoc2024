import strutils
import math
import sets
import deques

type Pos = tuple[x, y: int]
type
  Data = object
    m: seq[seq[int]]
    xsz, ysz: int

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    var r: seq[int]
    for c in line.strip():
      r.add(ord(c) - ord('0'))
    d.xsz = r.len
    d.m.add(r)
  d.ysz = d.m.len
  return d

proc getScore(fname: string): int =
  let d = getInput(fname)
  for r in 0..<d.ysz:
    for c in 0..<d.xsz:
      let n = d.m[r][c]
      if n != 0:
        continue
      var ninepos = initHashSet[Pos]()
      var paths = initHashSet[Pos]()
      paths.incl((x: c, y: r))
      # echo "y=", r, " x=", c
      while paths.len != 0:
        let p = paths.pop()
        let n = d.m[p.y][p.x]
        # echo "    n=", n, " y=", p.y, " x=", p.x
        if n == 9:
          ninepos.incl(p)
          continue
        let nn = n + 1
        let dir = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        for pp in dir:
          let y = pp[0] + p.y
          let x = pp[1] + p.x
          if y < 0 or y >= d.ysz or x < 0 or x >= d.xsz:
            continue
          if d.m[y][x] == nn:
            paths.incl((x: x, y: y))
      # echo "   Score: ", ninepos.len
      result += ninepos.len

assert getScore("ex0.txt") == 36

proc getRating(fname: string): int =
  let d = getInput(fname)
  for r in 0..<d.ysz:
    for c in 0..<d.xsz:
      let n = d.m[r][c]
      if n != 0:
        continue
      var paths: Deque[Pos]
      paths.addLast((x: c, y: r))
      # echo "y=", r, " x=", c
      var rating = 0
      while paths.len != 0:
        let p = paths.popFirst()
        let n = d.m[p.y][p.x]
        # echo "    n=", n, " y=", p.y, " x=", p.x
        if n == 9:
          rating += 1
          continue
        let nn = n + 1
        let dir = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        for pp in dir:
          let y = pp[0] + p.y
          let x = pp[1] + p.x
          if y < 0 or y >= d.ysz or x < 0 or x >= d.xsz:
            continue
          if d.m[y][x] == nn:
            paths.addLast((x: x, y: y))
      # echo "   Score: ", ninepos.len
      result += rating

assert getRating("ex0.txt") == 81

proc part1(fname: string): int =
  return getScore(fname)

proc part2(fname: string): int =
  return getRating(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
