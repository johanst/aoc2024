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

proc getInput(fname: string, swaps: Table[string, string] = initTable[string,
    string]()): Data =
  var d: Data
  var ops: seq[seq[string]]
  var reading_ops = false
  for line in lines(fname):
    let l = line.strip()
    var w = l.splitWhitespace()
    if not reading_ops:
      if l.len == 0:
        reading_ops = true
      else:
        d.addVal(w[0][0..2], parseInt(w[1]))
    else:
      d.addVal(w[0], 2)
      d.addVal(w[2], 2)
      if swaps.contains(w[4]):
        w[4] = swaps[w[4]]
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
        if fop != -1:
          echo swaps
          echo d.vseq[fop][0]
          echo d.vseq[opIdx][0]
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

proc getXIndices(d: Data): seq[int] =
  var cnt = 0
  while true:
    let xName = "x" & intToStr(cnt, 2)
    if not d.v2idx.contains(xName):
      break
    result.add(d.v2idx[xName])
    cnt += 1

proc getYIndices(d: Data): seq[int] =
  var cnt = 0
  while true:
    let yName = "y" & intToStr(cnt, 2)
    if not d.v2idx.contains(yName):
      break
    result.add(d.v2idx[yName])
    cnt += 1

proc getInitValuesForXY(d: Data, x, y: int): seq[int] =
  for v in d.vseq:
    result.add(v[1])
  var xx = x
  for xIdx in getXIndices(d):
    result[xIdx] = xx and 1
    xx = xx shr 1
  var yy = y
  for yIdx in getYIndices(d):
    result[yIdx] = yy and 1
    yy = yy shr 1


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
  # below worked
  # var swaps: Table[string, string]
  # swaps["qff"] = "qnw"
  # swaps["qnw"] = "qff"
  # let d = getInput(fname, swaps)
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
      echo i, ": ", d.opId(i), " -> ", "None"
    else:
      let op = d.ops[opId]
      echo i, ": ", d.opId(i), " -> ", d.opId(op.a), " ", op.op, " ", d.opId(
          op.b), " -> ", d.opId(op.c)

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
printStuff("input.txt")

proc simulateGrid(fname: string): int =
  # echo "--- Simulate"
  let d = getInput(fname)
  var grid = getInitValues(d)
  var zIdx = getZIndices(d)
  for zi in zIdx:
    let v = getWireValue(d, zi, grid)
    # echo d.vseq[zi][0], " = ", v
  return getZValue(d, grid)

assert simulateGrid("ex0.txt") == 2024

proc getWireValueNoCache(d: Data, idx: int, depth: int): int =
  if d.fan_in_ops[idx] == -1:
    echo " ".repeat(depth) & d.vseq[idx][0]
    return 0
  let op = d.ops[d.fan_in_ops[idx]]
  let aIdx = op.a
  let bIdx = op.b
  let a = getWireValueNoCache(d, aIdx, depth + 1)
  let b = getWireValueNoCache(d, bIdx, depth + 1)
  var c: int
  case op.op
  of AND:
    c = a and b
    echo " ".repeat(depth) & d.opId(idx) & " = " & d.opId(aIdx) & " AND " &
        d.opId(bIdx)
  of OR:
    c = a or b
    echo " ".repeat(depth) & d.opId(idx) & " = " & d.opId(aIdx) & " OR " &
        d.opId(bIdx)
  of XOR:
    c = a xor b
    echo " ".repeat(depth) & d.opId(idx) & " = " & d.opId(aIdx) & " XOR " &
        d.opId(bIdx)
  return c

proc followZ() =
  let d = getInput("input.txt")
  let zIdxs = getZIndices(d)
  for zIdx in zIdxs:
    echo "----- "
    discard getWireValueNoCache(d, zIdx, 0)
    echo "----- "
    echo ""

# levels = opIdx -> set[levels]
proc getWireValueNoteLevel(d: Data, idx: int, base_level: int,
    levels: var Table[int, HashSet[int]]): HashSet[int] =
  if not levels.contains(idx):
    levels[idx] = initHashSet[int]()
  if d.fan_in_ops[idx] == -1:
    levels[idx].incl(0 + base_level)
    var hs: HashSet[int]
    hs.incl(0 + base_level)
    return hs
  let op = d.ops[d.fan_in_ops[idx]]
  let aIdx = op.a
  let bIdx = op.b
  var aLvls = getWireValueNoteLevel(d, aIdx, base_level, levels)
  var bLvls = getWireValueNoteLevel(d, bIdx, base_level, levels)
  for aLvl in aLvls:
    levels[idx].incl(aLvl + 1)
    result.incl(aLvl + 1)
  for bLvl in bLvls:
    levels[idx].incl(bLvl + 1)
    result.incl(bLvl + 1)

proc getLevels() =
  let d = getInput("input.txt")
  let zIdxs = getZIndices(d)
  var levels: Table[int, HashSet[int]]
  for base_level, zIdx in zIdxs:
    if base_level > 1:
      break
    discard getWireValueNoteLevel(d, zIdx, base_level, levels)
  echo "--- Levels ---"
  for i, v in d.vseq:
    echo v[0] & " -> ", levels[i]

# getLevels()

proc simulateGridWithXY(fname: string, x, y: int, swaps: Table[string,
    string]): int =
  # echo "--- Simulate"
  let d = getInput(fname, swaps)
  var grid = getInitValuesForXY(d, x = x, y = y)
  var zIdx = getZIndices(d)
  for zi in zIdx:
    let v = getWireValue(d, zi, grid)
    # echo d.vseq[zi][0], " = ", v
  return getZValue(d, grid)

proc tryVal(x, y: int): bool =
  var swaps: Table[string, string]
  let z = simulateGridWithXY("input.txt", x = x, y = y, swaps)
  var ok = ""
  if z != x + y:
    ok = " ERR"
  echo toBin(z, 45) & ok

# mgj XOR wsv -> z12
# hbq -> z12 = bad swap (+1 error)
# ? mgj AND wsv -> hbq
proc tryStuff() =
  var swaps: Table[string, string]
  # swaps["z12"] = "hbq"
  # swaps["hbq"] = "z12"
  var n = 1
  for i in 0..44:
    let za = simulateGridWithXY("input.txt", x = n, y = 0, swaps)
    let zb = simulateGridWithXY("input.txt", x = 0, y = n, swaps)
    let zab = simulateGridWithXY("input.txt", x = n, y = n, swaps)
    if za != n or zb != n or zab != 2 * n:
      echo "z", i, ":"
      echo "  n0=", toBin(n, 45)
      echo " za0=", toBin(za, 45)
      echo " zb0=", toBin(za, 45)
      echo "zab0=", toBin(zab, 45)
    let nn = 1 shl 44 - 1
    let nMask = (1 shl (i + 1)) - 1
    let nnn = (n xor nn) and nMask
    let za1 = simulateGridWithXY("input.txt", x = nnn, y = 0, swaps)
    let zb1 = simulateGridWithXY("input.txt", x = 0, y = nnn, swaps)
    let zab1 = simulateGridWithXY("input.txt", x = nnn, y = nnn, swaps)
    if (za1 != (nnn)) or (zb1 != nnn) or (zab1 != 2 * (nnn)):
      echo "z", i, ":"
      echo "  n1=", toBin(nnn, 45)
      echo " za1=", toBin(za1, 45)
      echo " zb1=", toBin(za1, 45)
      echo "zab1=", toBin(zab1, 45)
    n *= 2

# tryStuff()

proc getWireValue2(d: Data, idx: int, s: var seq[int], ids: var HashSet[string],
    bad_swap: var bool, depth: int = 0): int =
  if depth > 100:
    bad_swap = true
    return 0
  if s[idx] != 2:
    return s[idx]
  ids.incl(d.vseq[idx][0])
  let op = d.ops[d.fan_in_ops[idx]]
  let aIdx = op.a
  let bIdx = op.b
  let a = getWireValue2(d, aIdx, s, ids, bad_swap, depth + 1)
  let b = getWireValue2(d, bIdx, s, ids, bad_swap, depth + 1)
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

proc simulateGridWithXY2(fname: string, x, y: int, swaps: Table[string, string],
     maxZIdx: int, wires: var HashSet[string], bad_swap: var bool): int =
  # echo "--- Simulate"
  let d = getInput(fname, swaps)
  var grid = getInitValuesForXY(d, x = x, y = y)
  var zIdx = getZIndices(d)
  for i in 0..maxZIdx:
    let zi = zIdx[i]
    let v = getWireValue2(d, zi, grid, wires, bad_swap)
    # echo d.vseq[zi][0], " = ", v
  return getZValue(d, grid)

proc getFirstBadZindex(swaps: Table[string, string], wires: var HashSet[string],
    bad_swap: var bool): int =
  # swaps["z12"] = "hbq"
  # swaps["hbq"] = "z12"
  var n = 1
  for i in 0..44:
    let za = simulateGridWithXY2("input.txt", x = n, y = 0, swaps, i + 1, wires, bad_swap)
    if bad_swap:
      return 0
    let zb = simulateGridWithXY2("input.txt", x = 0, y = n, swaps, i + 1, wires, bad_swap)
    if bad_swap:
      return 0
    let zab = simulateGridWithXY2("input.txt", x = n, y = n, swaps, i + 1,
        wires, bad_swap)
    if bad_swap:
      return 0
    if za != n or zb != n or zab != 2 * n:
      return i
      # echo "z", i, ":"
      # echo "  n0=", toBin(n, 45)
      # echo " za0=", toBin(za, 45)
      # echo " zb0=", toBin(za, 45)
      # echo "zab0=", toBin(zab, 45)
      # echo wires.len
    let nn = 1 shl 44 - 1
    let nMask = (1 shl (i + 1)) - 1
    let nnn = (n xor nn) and nMask
    let za1 = simulateGridWithXY2("input.txt", x = nnn, y = 0, swaps, i + 1,
        wires, bad_swap)
    if bad_swap:
      return 0
    let zb1 = simulateGridWithXY2("input.txt", x = 0, y = nnn, swaps, i + 1,
        wires, bad_swap)
    if bad_swap:
      return 0
    let zab1 = simulateGridWithXY2("input.txt", x = nnn, y = nnn, swaps, i + 1,
        wires, bad_swap)
    if bad_swap:
      return 0
    if (za1 != (nnn)) or (zb1 != nnn) or (zab1 != 2 * (nnn)):
      return i
      # echo "z", i, ":"
      # echo "  n1=", toBin(nnn, 45)
      # echo " za1=", toBin(za1, 45)
      # echo " zb1=", toBin(za1, 45)
      # echo "zab1=", toBin(zab1, 45)
    n *= 2
  return 100

type SwapCand = tuple[a: string, b: string, zbi: int]
type
  SwapCands = object
    badIdx: int
    sw: seq[SwapCand]

proc `<`(a, b: SwapCands): bool =
  a.badIdx > b.badIdx
# Bad zIdx: 11
  # qnw <-> wsv => 15
  # qnw <-> z12 => 12
  # qnw <-> qff => 15
proc knas(swaps: Table[string, string], bad_swaps: var Table[string, HashSet[
    string]]): seq[SwapCand] =
  let d = getInput("input.txt")
  var wires: HashSet[string]
  var dummyBadSwap: bool = false
  let zBadIdx = getFirstBadZIndex(swaps, wires, dummyBadSwap)
  assert not dummyBadSwap # should already be tested
  let w = wires.toseq
  echo "Bad zIdx: ", zBadIdx
  # 90 marks start of gates
  for i in 90..<d.vseq.len - 1:
    echo "count: ", i
    for j in i + 1..<d.vseq.len:
      let a = d.vseq[i][0]
      let b = d.vseq[j][0]
      if not bad_swaps.contains(a):
        bad_swaps[a] = initHashSet[string]()
      if not bad_swaps.contains(b):
        bad_swaps[b] = initHashSet[string]()
      if bad_swaps[a].contains(b) or bad_swaps[b].contains(a):
        continue
      if swaps.contains(a) or swaps.contains(b):
        continue
      var sw = swaps
      sw[a] = b
      sw[b] = a
      var wDummy: HashSet[string]
      var bad_swap = false
      let zbi = getFirstBadZIndex(sw, wDummy, bad_swap)
      if bad_swap:
        bad_swaps[a].incl(b)
        bad_swaps[b].incl(a)
      elif zbi > zBadIdx: # always look for something better
        result.add((a: a, b: b, zbi: zbi))

proc burk(): seq[SwapCands] =
  var hq: HeapQueue[SwapCands]
  var bad_swaps: Table[string, HashSet[string]]
  let sc0 = SwapCands(badIdx: 0, sw: @[])
  hq.push(sc0)
  while hq.len > 0:
    let s = hq.pop()
    echo "CHECKING ", s
    var swaps: Table[string, string]
    for sw in s.sw:
      swaps[sw[0]] = sw[1]
      swaps[sw[1]] = sw[0]
    let nsws = knas(swaps, bad_swaps)
    for nsw in nsws:
      var sNext = s
      sNext.sw.add(nsw)
      sNext.badIdx = nsw.zbi
      if nsw.zbi == 100:
        echo "SUCCESS for ", sNext
        result.add(sNext)
      elif sNext.sw.len >= 4:
        echo "FAILURE for ", sNext
      else:
        echo "WILL CHECK ", sNext
        hq.push(sNext)

let successCands = burk()
for s in successCands:
  echo successCands

# type CacheKey = tuple[opIdx: int, ]
# type Cache = Table[CacheKey, int]

# proc getWireValueWithCache(d: Data, idx: int, s: var seq[int], cache_ok: Cache,
#     cache_maybe: var Cache): int =
#   if s[idx] != 2:
#     return s[idx]
#   let opIdx = d.fan_in_ops[idx]
#   let op = d.ops[opIdx]
#   let aIdx = op.a
#   let bIdx = op.b
#   let a = getWireValueWithCache(d, aIdx, s)
#   let b = getWireValueWithCache(d, bIdx, s)
#   var c: int
#   case op.op
#   of AND:
#     c = a and b
#   of OR:
#     c = a or b
#   of XOR:
#     c = a xor b
#   s[idx] = c
#   return c

# followZ()

proc part1(fname: string): int =
  return simulateGrid(fname)

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
