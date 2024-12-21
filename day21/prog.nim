import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm
import heapqueue
import deques

let numpad: seq[string] =
  @[
    "789",
    "456",
    "123",
    "X0A"
  ]

let dirpad: seq[string] =
  @[
    "X^A",
    "<v>"
  ]

type
  Data = object
    codes: seq[string]
    npc2p: Table[char, int]           # code -> pos
    npp2c: Table[int, char]           # pos -> code
    npm: Table[int, seq[(char, int)]] # legal moves pos -> seq('<|v...', posn)
    dpc2p: Table[char, int]           # code -> pos
    dpp2c: Table[int, char]           # pos -> code
    dpm: Table[int, seq[(char, int)]] # legal moves pos -> seq('<|v...', posn)

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    d.codes.add(line.strip())
  for y in 0..3:
    for x in 0..2:
      let p = y * 3 + x
      d.npc2p[numpad[y][x]] = p
      d.npp2c[p] = numpad[y][x]
  for y in 0..3:
    for x in 0..2:
      if numpad[y][x] == 'X':
        continue
      let p = y * 3 + x
      var moves: seq[(char, int)]
      if y > 0:
        moves.add(('^', d.npc2p[numpad[y-1][x]]))
      if y < 3 and numpad[y+1][x] != 'X':
        moves.add(('v', d.npc2p[numpad[y+1][x]]))
      if x > 0 and numpad[y][x-1] != 'X':
        moves.add(('<', d.npc2p[numpad[y][x-1]]))
      if x < 2:
        moves.add(('>', d.npc2p[numpad[y][x+1]]))
      d.npm[p] = moves
  for y in 0..1:
    for x in 0..2:
      let p = y * 3 + x
      d.dpc2p[dirpad[y][x]] = p
      d.dpp2c[p] = dirpad[y][x]
  for y in 0..1:
    for x in 0..2:
      if dirpad[y][x] == 'X':
        continue
      let p = y * 3 + x
      var moves: seq[(char, int)]
      if y == 1:
        moves.add(('^', d.dpc2p[dirpad[y-1][x]]))
      if y == 0 and dirpad[y+1][x] != 'X':
        moves.add(('v', d.dpc2p[dirpad[y+1][x]]))
      if x > 0 and dirpad[y][x-1] != 'X':
        moves.add(('<', d.dpc2p[dirpad[y][x-1]]))
      if x < 2:
        moves.add(('>', d.dpc2p[dirpad[y][x+1]]))
      d.dpm[p] = moves
  return d

proc printStuff() =
  let d = getInput("ex0.txt")
  for i in 0..<12:
    if d.npm.contains(i):
      echo i, ":", d.npm[i]
  echo d.npc2p
  echo d.npp2c
  for i in 0..<6:
    if d.dpm.contains(i):
      echo i, ":", d.dpm[i]
  echo d.dpc2p
  echo d.dpp2c

# printStuff()

type
  State = object
    pushed: int   # number of times pressed
    dp0, dp1: int # dpop, controls dp0 which controls dp1
    np: int       # dp1 controls np

proc getInitState(d: Data): State =
  var s: State
  s.pushed = 0
  s.dp0 = d.dpc2p['A']
  s.dp1 = d.dpc2p['A']
  s.np = d.npc2p['A']
  return s

# echo getInitState(getInput("ex0.txt"))

proc dirpad_move(c: char, d: Data, fromp: int): int =
  for (cn, pn) in d.dpm[fromp]:
    if c == cn:
      return pn
  return -1

proc numpad_move(c: char, d: Data, fromp: int): int =
  for (cn, pn) in d.npm[fromp]:
    if c == cn:
      return pn
  return -1

proc pushButton(c: char, d: Data, s: State, code: string): (bool, State) =
  var sn: State = s
  if c == 'A':
    # Button push on dp0
    let c0 = d.dpp2c[s.dp0]
    if c0 == 'A':
      # Button push on dp1
      let c1 = d.dpp2c[s.dp1]
      if c1 == 'A':
        # Button push on numpad
        let ok = code[sn.pushed] == d.dpp2c[s.np]
        sn.pushed += 1
        return (ok, sn)
      else:
        # Move robot on numpad
        sn.np = numpad_move(c, d, s.np)
        let ok = sn.np != -1
        return (ok, sn)
    else:
      # Move robot on dp1
      sn.dp1 = dirpad_move(c0, d, s.dp1)
      let ok = sn.dp0 != -1
      return (ok, sn)
  else:
    # Move robot on dp0
    sn.dp0 = dirpad_move(c, d, s.dp0)
    let ok = sn.dp0 != -1
    return (ok, sn)

proc testSequence(pushseq: string, code: string) =
  let d = getInput("ex0.txt")
  var s = getInitState(d)
  for c in pushseq:
    var ok: bool
    (ok, s) = pushButton(c, d, s, code)
    assert ok
  assert s.pushed == 4

testSequence("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A", "029A")

proc getMinPushes(d: Data, code: string): int =
  let s0 = getInitState(d)
  var v: Table[State, int]
  var dq: Deque[(int, State)]
  v[s0] = 0
  dq.addLast((0, s0))
  while dq.len > 0:
    let (cost, s) = dq.popFirst()

assert getMinPushes(getInput("ex0.txt"), "029A") == 68

proc part1(fname: string): int =
  return 0

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
