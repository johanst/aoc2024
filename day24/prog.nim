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
  Operator = enum
    AND
    OR
    XOR

type
  Operation = object
    a, b, c: int
    op: Operator

type
  Data = object
    vseq: seq[(string, int)]          # name, initval (2 = None)
    v2idx: Table[string, int]
    ops: seq[Operation]
    fan_out: Table[int, seq[int]]     # sender -> receivers
    fan_out_ops: Table[int, seq[int]] # sender -> operationIdx
    fan_in_ops: seq[int]              # receiver -> operationIdx

type Signal = tuple[origin: int, val: int]

proc opId(d: Data, idx: int): string =
  return d.vseq[idx][0]

proc addVal(d: var Data, id: string, initVal: int) =
  if not d.v2idx.contains(id):
    d.vseq.add((id, initVal))
    d.v2idx[id] = d.vseq.len - 1

proc getInput(fname: string): Data =
  var d: Data
  var ops: seq[seq[string]]
  var reading_ops = false
  for line in lines(fname):
    let l = line.strip()
    let w = l.splitWhitespace()
    if not reading_ops:
      if l.len == 0:
        reading_ops = true
      else:
        d.addVal(w[0][0..2], parseInt(w[1]))
    else:
      d.addVal(w[0], 2)
      d.addVal(w[2], 2)
      d.addVal(w[4], 2)
      ops.add(w)
  for w in ops:
    var op: Operator
    if w[1] == "AND":
      op = AND
    elif w[1] == "OR":
      op = OR
    elif w[1] == "XOR":
      op = XOR
    else:
      assert false, "Illegal operation"
    d.ops.add(Operation(
      a: d.v2idx[w[0]], b: d.v2idx[w[2]], c: d.v2idx[w[4]], op: op))
  for v in 0..<d.vseq.len:
    var r: seq[int]
    var ro: seq[int]
    var fop = -1
    for opIdx, op in d.ops:
      if v == op.a or v == op.b:
        r.add(op.c)
        ro.add(opIdx)
      if op.c == v:
        assert fop == -1
        fop = opIdx
    d.fan_in_ops.add(fop)
    d.fan_out[v] = r
    d.fan_out_ops[v] = ro
  return d

proc getInitValues(d: Data): seq[int] =
  for v in d.vseq:
    result.add(v[1])

proc getZIndices(d: Data): seq[int] =
  var cnt = 0
  while true:
    let zName = "z" & intToStr(cnt, 2)
    if not d.v2idx.contains(zName):
      break
    result.add(d.v2idx[zName])
    cnt += 1

proc getZValue(d: Data, v: openArray[int]): int =
  var zseq: seq[int]
  let zidx = d.getZIndices()
  for i in zidx:
    var n = v[i]
    if n == 2:
      n = 0
    zseq.add(n)
  for i in countDown(zseq.len - 1, 0):
    result = result*2 + zseq[i]

proc testGetZValue() =
  let d = getInput("ex0.txt")
  var v = getInitValues(d)
  v[d.v2idx["z03"]] = 1
  v[d.v2idx["z05"]] = 1
  v[d.v2idx["z06"]] = 1
  v[d.v2idx["z07"]] = 1
  v[d.v2idx["z08"]] = 1
  v[d.v2idx["z09"]] = 1
  v[d.v2idx["z10"]] = 1
  assert getZValue(d, v) == 2024

testGetZValue()

proc printStuff(fname: string) =
  let d = getInput(fname)
  echo d.vseq
  echo d.vseq.len
  for k, v in d.v2idx:
    echo k, " -> ", v
  echo d.vseq
  for op in d.ops:
    echo d.opId(op.a), " ", op.op, " ", d.opId(op.b), " -> ", d.opId(op.c)
  echo "--- Fan out"
  for k, v in d.fan_out:
    var vstr: seq[string]
    for vv in v:
      vstr.add(d.opId(vv))
    echo d.opId(k), " -> ", vstr
  echo "--- Fan out Op"
  for k, v in d.fan_out_ops:
    echo d.opId(k), " -> ", v
  echo "--- Init values"
  echo d.getInitValues()
  echo "--- ZIndices"
  let zidx = d.getZIndices()
  for i, idx in zidx:
    echo "z", i, " = ", idx
  echo "--- Fan in Op"
  for i, opId in d.fan_in_ops:
    if opId == -1:
      echo d.opId(i), " -> ", "None"
    else:
      let op = d.ops[opId]
      echo d.opId(i), " -> ", d.opId(op.a), " ", op.op, " ", d.opId(op.b),
          " -> ", d.opId(op.c)

proc getWireValue(d: Data, idx: int, s: var seq[int]): int =
  if s[idx] != 2:
    return s[idx]
  let op = d.ops[d.fan_in_ops[idx]]
  let aIdx = op.a
  let bIdx = op.b
  let a = getWireValue(d, aIdx, s)
  let b = getWireValue(d, bIdx, s)
  var c: int
  case op.op
  of AND:
    c = a and b
  of OR:
    c = a or b
  of XOR:
    c = a xor b
  s[idx] = c
  return c

# printStuff("ex0.txt")
# printStuff("input.txt")

proc simulateGrid(fname: string): int =
  # echo "--- Simulate"
  let d = getInput(fname)
  var grid = getInitValues(d)
  var zIdx = getZIndices(d)
  for zi in zIdx:
    let v = getWireValue(d, zi, grid)
    # echo d.vseq[zi][0], " = ", v
  return getZValue(d, grid)

  # var zRcvd: HashSet[int]
  # var dq: Deque[int] # Operations that should be performed
  # for idx, v in grid:
  #   if v != 2:
  #     dq.addLast(idx)
  #     dq.addLast((origin: idx, val: v))
  # while dq.len > 0:
  #   let s = dq.popFirst()
  #   echo d.vseq[s.origin][0], " -> ", s.val
  #   grid[s.origin] = s.val
  #   if s.origin in zIdx:
  #     zRcvd.incl(s.origin)
  #     if zIdx.len == zRcvd.len:
  #       return getZValue(d, grid)
  #   for op in d.fan_out_ops[s.origin]:
  #     echo op
  #     let a = grid[d.ops[op].a]
  #     let b = grid[d.ops[op].b]
  #     assert a < 2
  #     assert b < 2
  #     var c: int
  #     case d.ops[op].op
  #     of AND:
  #       c = a and b
  #     of OR:
  #       c = a or b
  #     of XOR:
  #       c = a xor b
  #     grid[d.ops[p].c] = c
  #     dq.addLast((origin: d.ops[op].c, val: c))

assert simulateGrid("ex0.txt") == 2024

proc part1(fname: string): int =
  return simulateGrid(fname)

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
