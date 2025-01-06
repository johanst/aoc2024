import strutils
import sequtils
import algorithm
import tables
import deques

type
  Data = object
    before: Table[int, seq[int]]
    lines: seq[seq[int]]

proc getInput(fname: string): Data =
  var data: Data
  for line in lines(fname):
    let line = line.strip()
    if line.contains('|'):
      let w = line.split('|')
      let a = parseInt(w[0])
      let b = parseInt(w[1])
      if not data.before.contains(a):
        data.before[a] = @[]
      data.before[a].add(b)
    elif line.len > 0:
      let w = line.split(',')
      let wi = w.map(proc(s: string): int = parseInt(s))
      data.lines.add(wi)
  return data

let exData = getInput("ex0.txt")

proc isValidOrder(d: Data, l: openArray[int]): bool =
  for i in 0..l.len-2:
    for j in i+1..l.len-1:
      let a = l[i]
      let b = l[j]
      # a < b ok if it does have to be after
      if b in d.before and d.before[b].contains(a):
        # echo a, " ", b
        return false
  return true

proc getMiddleSum(fname: string): int =
  let d = getInput(fname)
  for l in d.lines:
    if d.isValidOrder(l):
      result += l[l.len div 2]

assert exData.isValidOrder(exData.lines[0])
assert not exData.isValidOrder([75, 97, 47, 61, 53])
assert getMiddleSum("ex0.txt") == 143

proc getIncorrectlySorted(d: Data): seq[seq[int]] =
  result = @[]
  for l in d.lines:
    if not d.isValidOrder(l):
      result.add(l)

proc getMiddleSum2(fname: string): int =
  let d = getInput(fname)
  let unsorted = d.getIncorrectlySorted()
  for us in unsorted:
    var s = us
    s.sort(
      proc(a: int, b: int): int =
      if d.before.contains(a) and d.before[a].contains(b):
        return -1
      elif d.before.contains(b) and d.before[b].contains(a):
        return 1
      else:
        return 0
    )
    result += s[s.len div 2]

assert getMiddleSum2("ex0.txt") == 123

# For fun trying topological sort as described in Introduction to Algorithms.
proc topoVisit(d: Data, p: int, v: var Table[int, bool], sl: var Deque[int]) =
  v[p] = true
  if d.before.contains(p):
    for pa in d.before[p]:
      if v.contains(pa) and not v[pa]:
        topoVisit(d, pa, v, sl)
  sl.addFirst(p)

proc topologicalSort(d: Data, l: seq[int]): seq[int] =
  var sl: Deque[int]
  var v: Table[int, bool]
  for p in l:
    v[p] = false
  for p in l:
    if not v[p]:
      topoVisit(d, p, v, sl)
  return sl.toSeq()

proc getMiddleSum3(fname: string): int =
  let d = getInput(fname)
  for l in d.lines:
    let ls = topologicalSort(d, l)
    if l != ls:
      result += ls[ls.len div 2]

assert getMiddleSum3("ex0.txt") == 123

proc part1(fname: string): int =
  return getMiddleSum("input.txt")

proc part2(fname: string): int =
  return getMiddleSum2("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
echo "Part2: (using topological sort): ", getMiddleSum3("input.txt")
