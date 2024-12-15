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
    m: seq[string]
    mvs: seq[Pos]
    x0, y0: int

type
  State = object
    m: seq[string]
    x, y: int

proc getInput(fname: string): Data =
  var d: Data
  var mdone: bool = false
  var yidx = 0
  for line in lines(fname):
    var l = line.strip()
    if mdone:
      for c in l:
        case c
        of '<':
          d.mvs.add((x: -1, y: 0))
        of '>':
          d.mvs.add((x: 1, y: 0))
        of '^':
          d.mvs.add((x: 0, y: -1))
        of 'v':
          d.mvs.add((x: 0, y: 1))
        else:
          assert false, "Unknown direction"
    elif l.len == 0:
      mdone = true
    else:
      let xidx = l.find('@')
      if xidx != -1:
        (d.x0, d.y0) = (xidx, yidx)
        l[xidx] = '.'
      else:
        yidx += 1
      d.m.add(l)
  return d

proc moveRobot(s: var State, dir: Pos) =
  var p = (x: s.x + dir.x, y: s.y + dir.y)
  if s.m[p.y][p.x] == '.':
    s.x = p.x
    s.y = p.y
    return
  elif s.m[p.y][p.x] == '#':
    return
  var pp = (x: p.x + dir.x, y: p.y + dir.y)
  while s.m[pp.y][pp.x] == 'O':
    pp = (x: pp.x + dir.x, y: pp.y + dir.y)
  if s.m[pp.y][pp.x] == '.':
    s.x = p.x
    s.y = p.y
    s.m[p.y][p.x] = '.'
    s.m[pp.y][pp.x] = 'O'

proc drawMap(s: State) =
  for y, l in s.m:
    var ll = l
    if y == s.y:
      ll[s.x] = '@'
    echo ll

proc runSmallExample() =
  let d = getInput("ex0.txt")
  var s: State
  s.m = d.m
  s.x = d.x0
  s.y = d.y0
  echo "Initial state:"
  drawMap(s)
  for mv in d.mvs:
    echo "Move", mv, ":"
    moveRobot(s, mv)
    drawMap(s)

# runSmallExample()

proc getSumGps(fname: string): int =
  let d = getInput(fname)
  var s: State
  s.m = d.m
  s.x = d.x0
  s.y = d.y0
  for mv in d.mvs:
    moveRobot(s, mv)
  for y, l in s.m:
    for x, c in l:
      if c == 'O':
        result += 100 * y + x

assert getSumGps("ex1.txt") == 10092

proc getInput2(fname: string): Data =
  let d1 = getInput(fname)
  var d: Data
  (d.x0, d.y0, d.mvs) = (d1.x0, d1.y0, d1.mvs)
  for l1 in d1.m:
    var l: string
    for c1 in l1:
      case c1
      of 'O':
        l.add("[]")
      of '#':
        l.add("##")
      of '.':
        l.add("..")
      else:
        assert false, "Invalid map"
    d.m.add(l)
  return d

proc maybeMoveBox(s: var State, b: Pos, dir: Pos): bool =
  var canMove = false
  if dir.y == 0:
    if dir.x == -1:
      let nb = s.m[b.y][b.x-1]
      if nb == ']':
        if not maybeMoveBox(s, (x: b.x - 2, y: b.y), dir):
          return false
      if s.m[b.y][b.x-1] == '.':
        s.m[b.y][b.x-1] = '['
        s.m[b.y][b.x] = ']'
        s.m[b.y][b.x+1] = '.'
        canMove = true
    elif dir.x == 1:
      let nb = s.m[b.y][b.x+2]
      if nb == '[':
        if not maybeMoveBox(s, (x: b.x + 2, y: b.y), dir):
          return false
      if s.m[b.y][b.x+2] == '.':
        s.m[b.y][b.x] = '.'
        s.m[b.y][b.x+1] = '['
        s.m[b.y][b.x+2] = ']'
        canMove = true
    else:
      assert false, "Invalid x direction"
  else:
    for dx in 0..1:
      let nb = s.m[b.y + dir.y][b.x + dx]
      case nb
      of '[':
        canMove = maybeMoveBox(s, (x: b.x + dx, y: b.y + dir.y), dir)
      of ']':
        canMove = maybeMoveBox(s, (x: b.x + dx - 1, y: b.y + dir.y), dir)
      of '#':
        canMove = false
      of '.':
        canMove = true
      else:
        assert false, "Invalid map"
      if not canMove:
        return false
    s.m[b.y + dir.y][b.x] = '['
    s.m[b.y + dir.y][b.x + 1] = ']'
    s.m[b.y][b.x] = '.'
    s.m[b.y][b.x+1] = '.'
  return canMove

proc moveRobot2(s: var State, dir: Pos) =
  var sMaybe = s
  var p = (x: s.x + dir.x, y: s.y + dir.y)
  var canMove = false
  let nb = s.m[p.y][p.x]
  case nb
  of '.':
    canMove = true
  of '[':
    canMove = maybeMoveBox(sMaybe, (x: p.x, y: p.y), dir)
  of ']':
    canMove = maybeMoveBox(sMaybe, (x: p.x - 1, y: p.y), dir)
  of '#':
    canMove = false
  else:
    assert false, "Invalid map"
  if canMove:
    s.m = sMaybe.m
    s.x = p.x
    s.y = p.y

proc runSmallExample2() =
  let d = getInput2("ex2.txt")
  var s: State
  s.m = d.m
  s.x = d.x0 * 2
  s.y = d.y0
  echo "Initial state:"
  drawMap(s)
  for mv in d.mvs:
    echo "Move", mv, ":"
    moveRobot2(s, mv)
    drawMap(s)

# runSmallExample2()

proc getSumGps2(fname: string): int =
  let d = getInput2(fname)
  var s: State
  s.m = d.m
  s.x = d.x0 * 2
  s.y = d.y0
  for mv in d.mvs:
    moveRobot2(s, mv)
  for y, l in s.m:
    for x, c in l:
      if c == '[':
        result += 100 * y + x

assert getSumGps2("ex1.txt") == 9021

proc part1(fname: string): int =
  return getSumGps("input.txt")

proc part2(fname: string): int =
  return getSumGps2("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
