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
    m: seq[(string, string)] # connections one-one
    mm: Table[string, HashSet[string]]
    cs: seq[string]

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    let l = line.strip()
    assert l.len == 5
    d.m.add((l[0..1], l[3..4]))
  for (l, r) in d.m:
    if not d.mm.contains(l):
      d.mm[l] = initHashSet[string]()
    if not d.mm.contains(r):
      d.mm[r] = initHashSet[string]()
    d.mm[l].incl(r)
    d.mm[r].incl(l)
  for c in d.mm.keys:
    d.cs.add(c)
  return d

proc printStuff() =
  let d = getInput("ex0.txt")
  echo d.m.len
  echo d.m
  for k, v in d.mm:
    echo k, " -> ", v
  echo d.cs

printStuff()

proc getGroupsOfThree(d: Data, treq: bool = false): HashSet[seq[string]] =
  for i in 0..<d.cs.len - 1:
    for j in i + 1..<d.cs.len:
      if not d.mm[d.cs[i]].contains(d.cs[j]):
        continue
      let isec = intersection(d.mm[d.cs[i]], d.mm[d.cs[j]])
      for c in isec:
        let a = d.cs[i]
        let b = d.cs[j]
        let hasT = a.startsWith('t') or b.startsWith('t') or c.startsWith('t')
        if not treq or hasT:
          var sq: seq[string] = @[a, b, c]
          sort(sq)
          result.incl(sq)

proc getNumGroupsOfThree(fname: string): int =
  let d = getInput(fname)
  let sq = getGroupsOfThree(d, treq = true)
  # for s in sq:
  #   echo s
  # echo sq.len
  return sq.len

assert getNumGroupsOfThree("ex0.txt") == 7

proc getEvenLargerGroup(d: Data, combos: HashSet[seq[string]],
    dbg: bool = false): HashSet[seq[string]] =
  for sqseq in combos:
    # if dbg:
    #   echo sqseq
    var sq: HashSet[string]
    for c in sqseq:
      sq.incl(c)
    # Now try to bring in a new guest
    for c in d.cs:
      if sq.contains(c):
        # already in group
        # if dbg:
        #   echo c, " already in ", sqseq
        continue
      var ok = true
      for a in sq:
        if not d.mm[a].contains(c):
          # if dbg:
          #   echo a, " not connected with ", c, " for ", sqseq
          ok = false
          break
      if not ok:
        continue
      var sqn = sqseq
      sqn.add(c)
      sort(sqn)
      result.incl(sqn)

proc getLargestGroup(fname: string): string =
  let d = getInput(fname)
  var g = getGroupsOfThree(d)
  var length = 3
  while g.len > 1:
    echo "Group size ", length, " => ", g.len, " elements"
    let dbg: bool = length == 4
    g = getEvenLargerGroup(d, g, dbg)
    length += 1
  let gseq = g.toSeq[0]
  return gseq.join(",")

assert getLargestGroup("ex0.txt") == "co,de,ka,ta"

proc part1(fname: string): int =
  return getNumGroupsOfThree(fname)

proc part2(fname: string): string =
  return getLargestGroup(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
