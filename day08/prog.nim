import strutils
import math
import tables
import algorithm
import sets

type Pos = tuple[x, y: int]
type
  Data = object
    lines: seq[string]
    xsz, ysz: int
    m: Table[char, seq[Pos]]

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    let line = line.strip()
    d.lines.add(line)
    d.xsz = line.len
    for i, c in line:
      let c = line[i]
      if c == '.':
        continue
      if d.m.contains(c):
        d.m[c].add((x: i, y: d.ysz))
      else:
        d.m[c] = @[(x: i, y: d.ysz)]
    d.ysz += 1
  return d

proc drawMap(d: Data, ans: HashSet[Pos]) =
  for y in 0..<d.ysz:
    var l = ""
    for x in 0..<d.xsz:
      let c = d.lines[y][x]
      if c != '.':
        l.add(c)
      elif (x: x, y: y) in ans:
        l.add('#')
      else:
        l.add('.')
    echo l

proc getAntiNodes(d: Data, ap, bp: Pos): seq[Pos] =
  result = @[]
  let dx = bp.x - ap.x
  let dy = bp.y - ap.y
  var x = ap.x - dx
  var y = ap.y - dy
  if x >= 0 and x < d.xsz and y >= 0 and y < d.ysz:
    result.add((x: x, y: y))
  x = bp.x + dx
  y = bp.y + dy
  if x >= 0 and x < d.xsz and y >= 0 and y < d.ysz:
    result.add((x: x, y: y))

proc countUniqueAntiNodesCommon(
  fname: string,
  getAntiNodesFunc: proc(d: Data, ap, bp: Pos): seq[Pos]): int =
  let d = getInput(fname)
  var ans = initHashSet[Pos]()
  for c, nodes in d.m:
    # echo c, " ", nodes
    if nodes.len < 2:
      continue
    var ns = nodes
    sort(ns)
    for i in 0..<ns.len-1:
      for j in i+1..<ns.len:
        let ap = ns[i]
        let bp = ns[j]
        # echo ap, " ", bp
        let nans = getAntiNodesFunc(d, ap, bp)
        # echo nans
        for an in nans:
          ans.incl(an)
  # drawMap(d, ans)
  return ans.len

proc countUniqueAntiNodes(fname: string): int =
  return countUniqueAntiNodesCommon(fname, getAntiNodes)

assert countUniqueAntiNodes("ex0.txt") == 14

proc getAntiNodes2(d: Data, ap, bp: Pos): seq[Pos] =
  result = @[ap]
  let dx = bp.x - ap.x
  let dy = bp.y - ap.y
  var x = ap.x
  var y = ap.y
  while true:
    x -= dx
    y -= dy
    if x >= 0 and x < d.xsz and y >= 0 and y < d.ysz:
      result.add((x: x, y: y))
    else:
      break
  x = ap.x
  y = ap.y
  while true:
    x += dx
    y += dy
    if x >= 0 and x < d.xsz and y >= 0 and y < d.ysz:
      result.add((x: x, y: y))
    else:
      break

proc countUniqueAntiNodes2(fname: string): int =
  return countUniqueAntiNodesCommon(fname, getAntiNodes2)

assert countUniqueAntiNodes2("ex0.txt") == 34

proc part1(fname: string): int =
  return countUniqueAntiNodes("input.txt")

proc part2(fname: string): int =
  return countUniqueAntiNodes2("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
