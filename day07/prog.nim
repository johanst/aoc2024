import strutils
import sequtils
import sets
import math

type
  Data = object
    res: int
    op: seq[int]

proc getInput(fname: string): seq[Data] =
  var d: seq[Data]
  for line in lines(fname):
    var dd: Data
    let w = line.strip().split(':')
    dd.res = parseInt(w[0])
    let wop = w[1].splitWhitespace()
    for op in wop:
      dd.op.add(parseInt(op))
    d.add(dd)
  return d

proc getCalibration(d: Data): int =
  let n = 2 ^ (d.op.len - 1)
  for i in 0..<n:
    var res = d.op[0]
    for j in 0..<d.op.len-1:
      if ((2 ^ j) and i) != 0:
        res *= d.op[j+1]
      else:
        res += d.op[j+1]
    if res == d.res:
      return d.res
  return 0

let exData = getInput("ex0.txt")
assert getCalibration(Data(res: 190, op: @[10, 19])) == 190

proc getCalibrationSum(fname: string): int =
  let d = getInput(fname)
  for dd in d:
    result += getCalibration(dd)

assert getCalibrationSum("ex0.txt") == 3749

# proc getNumVisited(fname: string): int =
#   let d = getInput(fname)
#   var v: seq[seq[bool]]
#   for _ in 0..<d.map.len:
#     v.add(newSeq[bool](d.map[0].len))
#   v[d.y0][d.x0] = true

#   let ysz = v.len
#   let xsz = v[0].len
#   var x = d.x0
#   var y = d.y0
#   var dx = 0
#   var dy = -1
#   while true:
#     var xx = x + dx
#     var yy = y + dy
#     if xx < 0 or xx >= xsz or yy < 0 or yy >= ysz:
#       break
#     elif d.map[yy][xx] == '#':
#       if (dy, dx) == (-1, 0):
#         (dy, dx) = (0, 1)
#       elif (dy, dx) == (0, 1):
#         (dy, dx) = (1, 0)
#       elif (dy, dx) == (1, 0):
#         (dy, dx) = (0, -1)
#       elif (dy, dx) == (0, -1):
#         (dy, dx) = (-1, 0)
#       else:
#         assert false, "WTF"
#       continue
#     y = yy
#     x = xx
#     v[y][x] = true

#   for vr in v:
#     result += countIt(vr, it)

# assert getNumVisited("ex0.txt") == 41

# type GuardState =
#   tuple[x: int, y: int, dx: int, dy: int]

# proc hasLoop(d: Data, xo, yo: int): bool =
#   var v = initHashSet[GuardState]()
#   v.incl((x: d.x0, y: d.y0, dx: 0, dy: -1))

#   let ysz = d.map.len
#   let xsz = d.map[0].len
#   var x = d.x0
#   var y = d.y0
#   var dx = 0
#   var dy = -1
#   while true:
#     var xx = x + dx
#     var yy = y + dy
#     # echo (x: x, y: y, dx: dx, dy: dy)
#     if xx < 0 or xx >= xsz or yy < 0 or yy >= ysz:
#       # echo "false after ", v.len
#       return false
#     var c = d.map[yy][xx]
#     if yy == yo and xx == xo:
#       c = '#'
#     if c == '#':
#       if (dy, dx) == (-1, 0):
#         (dy, dx) = (0, 1)
#       elif (dy, dx) == (0, 1):
#         (dy, dx) = (1, 0)
#       elif (dy, dx) == (1, 0):
#         (dy, dx) = (0, -1)
#       elif (dy, dx) == (0, -1):
#         (dy, dx) = (-1, 0)
#       else:
#         assert false, "WTF"
#     else:
#       y = yy
#       x = xx
#     let st = (x: x, y: y, dx: dx, dy: dy)
#     if v.contains(st):
#       # echo "true after ", v.len
#       return true
#     v.incl(st)

# proc getNumLoops(fname: string): int =
#   let d = getInput(fname)
#   for y in 0..<d.map.len:
#     for x in 0..<d.map[0].len:
#       if y == d.y0 and x == d.x0 or d.map[y][x] == '#':
#         continue
#       if hasLoop(d, x, y):
#         result += 1

# let exData = getInput("ex0.txt")
# assert hasLoop(exData, exData.x0 - 1, exData.y0)

# echo getNumLoops("ex0.txt")
# assert getNumLoops("ex0.txt") == 6

# 414138 not correct
proc part1(fname: string): int =
  return getCalibrationSum(fname)

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
