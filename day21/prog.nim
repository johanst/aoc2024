import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm
import heapqueue

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

printStuff()

proc part1(fname: string): int =
  return 0

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
