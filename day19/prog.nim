import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm

type
  Data = object
    tp: HashSet[string]
    tpm: Table[int, HashSet[string]]
    pmax: int
    td: seq[string]

proc getInput(fname: string): Data =
  var d: Data
  var fdone: bool = false
  for line in lines(fname):
    var l = line.strip()
    if fdone:
      d.td.add(l)
    elif l.len == 0:
      fdone = true
    else:
      let ws = l.split(',')
      for ww in ws:
        let w = ww.strip()
        d.pmax = max(d.pmax, w.len)
        if not d.tpm.contains(w.len):
          d.tpm[w.len] = initHashSet[string]()
        d.tpm[w.len].incl(w)
        d.tp.incl(w)
  return d

proc isPossible(d: Data, s: string, offset: int, bad: var HashSet[int]): bool =
  if offset in bad:
    return false
  if offset == s.len:
    return true
  for n in 1..min(d.pmax, s.len - offset):
    # echo "offset=", offset, " n=", n
    # echo s[offset..<offset + n]
    # echo d.tpm[n]
    if s[offset..<offset + n] in d.tpm[n]:
      if isPossible(d, s, offset + n, bad):
        return true
  bad.incl(offset)
  return false

proc getNumPossible(fname: string): int =
  let d = getInput(fname)
  for s in d.td:
    # echo s
    var bad: HashSet[int]
    if isPossible(d, s, 0, bad):
      result += 1
    #   echo "OK"
    # else:
    #   echo "Nope"

  # let d = getInput("ex0.txt")
  # assert isPossible(d, "bwurrg", 0)
  # assert false
assert getNumPossible("ex0.txt") == 6

proc numPossibles(d: Data, s: string, offset: int, cache: var Table[int, int]): int =
  if offset in cache:
    return cache[offset]
  if offset == s.len:
    return 1
  for n in 1..min(d.pmax, s.len - offset):
    # echo "offset=", offset, " n=", n
    # echo s[offset..<offset + n]
    # echo d.tpm[n]
    if s[offset..<offset + n] in d.tpm[n]:
      result += numPossibles(d, s, offset + n, cache)
  cache[offset] = result

let d = getInput("ex0.txt")
var cache: Table[int, int]
assert numPossibles(d, "rrbgbr", 0, cache) == 6

proc getTotNumPossible(fname: string): int =
  let d = getInput(fname)
  for s in d.td:
    # echo s
    var cache: Table[int, int]
    let n = numPossibles(d, s, 0, cache)
    # echo n
    result += n

proc part1(fname: string): int =
  return getNumPossible("input.txt")

proc part2(fname: string): int =
  return getTotNumPossible("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
