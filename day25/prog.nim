import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm
import heapqueue
import deques

type
  Data = object
    keys: seq[seq[int]]
    locks: seq[seq[int]]

proc getInput(fname: string): Data =
  var d: Data
  var kl = newSeqWith[5, 0]
  var isKey = false
  var isLock = false
  var cnt = -1
  for line in lines(fname):
    let l = line.strip()
    if not isKey and not isLock:
      if l == "#####":
        isLock = true
        cnt = 0
      elif l == ".....":
        isKey = true
        cnt = 0
    elif isKey:
      cnt += 1
      if cnt == 6:
        d.keys.add(kl)
        kl = newSeqWith[5, 0]
        isKey = false
      else:
        for i, c in l:
          if c == '#':
            kl[i] += 1
    elif isLock:
      cnt += 1
      if cnt == 6:
        d.locks.add(kl)
        kl = newSeqWith[5, 0]
        isLock = false
      else:
        for i, c in l:
          if c == '#':
            kl[i] += 1
  return d

proc printStuff(fname: string) =
  let d = getInput(fname)
  echo "keys"
  for key in d.keys:
    echo key
  echo "locks"
  for lock in d.locks:
    echo lock
  echo d

printStuff("input.txt")

proc keyFits(key, lock: seq[int]): bool =
  for i in 0..<key.len:
    if key[i] + lock[i] > 5:
      return false
  return true

proc getNumFits(fname: string): int =
  let d = getInput(fname)
  for key in d.keys:
    for lock in d.locks:
      if keyFits(key, lock):
        result += 1

assert getNumFits("ex0.txt") == 3

proc part1(fname: string): int =
  return getNumFits("input.txt")

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
