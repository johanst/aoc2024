import strutils
import sequtils
import algorithm
import tables

type
  Data = object
    map: seq[string]
    x0: int
    y0: int

proc getInput(fname: string): Data =
  var data: Data
  var count = 0
  for line in lines(fname):
    var line = line.strip()
    let pos = line.find('^')
    if pos != -1:
      data.y0 = count
      data.x0 = pos
      line[data.x0] = '.'
    data.map.add(line)
    count += 1
  return data

proc getNumVisited(fname: string): int =
  let d = getInput(fname)
  var v: seq[seq[bool]]
  for _ in 0..<d.map.len:
    v.add(newSeq[bool](d.map[0].len))
  v[d.y0][d.x0] = true

  let ysz = v.len
  let xsz = v[0].len
  var x = d.x0
  var y = d.y0
  var dx = 0
  var dy = -1
  while true:
    var xx = x + dx
    var yy = y + dy
    if xx < 0 or xx >= xsz or yy < 0 or yy >= ysz:
      break
    elif d.map[yy][xx] == '#':
      if (dy, dx) == (-1, 0):
        (dy, dx) = (0, 1)
      elif (dy, dx) == (0, 1):
        (dy, dx) = (1, 0)
      elif (dy, dx) == (1, 0):
        (dy, dx) = (0, -1)
      elif (dy, dx) == (0, -1):
        (dy, dx) = (-1, 0)
      else:
        assert false, "WTF"
      continue
    y = yy
    x = xx
    v[y][x] = true

  for vr in v:
    result += countIt(vr, it)

assert getNumVisited("ex0.txt") == 41

proc part1(fname: string): int =
  return getNumVisited("input.txt")

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
