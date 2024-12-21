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

type Pos = tuple[x, y: int]
type
  Data = object
    codes: seq[string]
    npc2p: Table[char, int]           # code -> pos
    npp2c: Table[int, char]           # pos -> code
    npm: Table[int, seq[(char, int)]] # legal moves pos -> seq('<|v...', posn)
    npms: Table[(char, char), seq[string]] # (from, to) -> Possible sequences numpad
    dpc2p: Table[char, int]           # code -> pos
    dpp2c: Table[int, char]           # pos -> code
    dpm: Table[int, seq[(char, int)]] # legal moves pos -> seq('<|v...', posn)
    dpms: Table[(char, char), seq[string]] # (from, to) -> Possible sequences dirpad

proc getPadFromToSeqs(pad: seq[string], x, y: int, cf, ct: char): seq[string] =
  let ysz = pad.len
  let xsz = pad[0].len
  var dq: Deque[(Pos, string)]
  var optlen = high(int)
  var sqs: seq[string]
  let p0: Pos = (x: x, y: y)
  let sq0 = ""
  dq.addLast((p0, sq0))
  while dq.len > 0:
    let (p, sq) = dq.popFirst()
    let c = pad[p.y][p.x]
    if c == ct:
      optlen = sq.len
      var sqn = sq
      sqn.add('A')
      sqs.add(sqn)
      continue
    if sq.len >= optlen:
      continue
    let directions = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    let dirchar = "<^>v"
    for i, delta in directions:
      let (dx, dy) = (delta[0], delta[1])
      let pp = (x: p.x + dx, y: p.y + dy)
      if pp.x < 0 or pp.x >= xsz or pp.y < 0 or pp.y >= ysz:
        continue
      if pad[pp.y][pp.x] == 'X':
        continue
      var sqn = sq
      sqn.add(dirchar[i])
      dq.addLast((pp, sqn))
  return sqs

proc getPadSeqs(pad: seq[string]): Table[(char, char), seq[string]] =
  let ysz = pad.len
  let xsz = pad[0].len
  var sq_seqs: Table[(char, char), seq[string]]
  for y in 0..<ysz:
    for x in 0..<xsz:
      let cf = pad[y][x]
      if cf == 'X':
        continue
      for yy in 0..<ysz:
        for xx in 0..<xsz:
          let ct = pad[yy][xx]
          if ct == 'X':
            continue
          sq_seqs[(cf, ct)] = getPadFromToSeqs(pad, x, y, cf, ct)
  return sq_seqs

proc fillNpms(d: var Data) =
  d.npms = getPadSeqs(numpad)

proc fillDpms(d: var Data) =
  d.dpms = getPadSeqs(dirpad)

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
      if y > 0 and numpad[y-1][x] != 'X':
        moves.add(('^', d.npc2p[numpad[y-1][x]]))
      if y < 3 and numpad[y+1][x] != 'X':
        moves.add(('v', d.npc2p[numpad[y+1][x]]))
      if x > 0 and numpad[y][x-1] != 'X':
        moves.add(('<', d.npc2p[numpad[y][x-1]]))
      if x < 2 and numpad[y][x+1] != 'X':
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
      if y == 1 and dirpad[y-1][x] != 'X':
        moves.add(('^', d.dpc2p[dirpad[y-1][x]]))
      if y == 0 and dirpad[y+1][x] != 'X':
        moves.add(('v', d.dpc2p[dirpad[y+1][x]]))
      if x > 0 and dirpad[y][x-1] != 'X':
        moves.add(('<', d.dpc2p[dirpad[y][x-1]]))
      if x < 2 and dirpad[y][x+1] != 'X':
        moves.add(('>', d.dpc2p[dirpad[y][x+1]]))
      d.dpm[p] = moves
  fillNpms(d)
  fillDpms(d)
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
  # echo " --- numpad ---"
  # for fromto, sq in d.npms:
  #   echo fromto, " -> ", sq
  # echo " --- dirpad ---"
  # for fromto, sq in d.dpms:
  #   echo fromto, " -> ", sq

printStuff()

type
  State = object
    pushed: int  # number of times pressed
    dp: seq[int] # dpop, controls dp[0] which controls dp[1], ...
    np: int      # dp1 controls np

type
  StateAndCost = object
    cost: int
    s: State

proc `<`(a, b: StateAndCost): bool =
  # if a.s.pushed > b.s.pushed:
  #   return true
  if a.cost < b.cost:
    return true
  return false

proc getInitState(d: Data, nrkpd: int): State =
  var s: State
  s.pushed = 0
  s.dp = newSeqWith(nrkpd, d.dpc2p['A'])
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
  var cidx = c
  # dirpads
  for i in 0..<s.dp.len:
    if cidx == 'A':
      # Button push on dpx
      cidx = d.dpp2c[s.dp[i]]
    else:
      # Move robot on dpx
      sn.dp[i] = dirpad_move(cidx, d, s.dp[i])
      let ok = sn.dp[i] != -1
      return (ok, sn)
  if cidx == 'A':
    # Button push on numpad
    let ok = code[sn.pushed] == d.npp2c[s.np]
    # echo "PUSH ", code[sn.pushed]
    sn.pushed += 1
    return (ok, sn)
  else:
    # Move robot on numpad
    sn.np = numpad_move(cidx, d, s.np)
    let ok = sn.np != -1
    return (ok, sn)

proc testSequence(pushseq: string, code: string) =
  let d = getInput("ex0.txt")
  var s = getInitState(d, 2)
  echo s
  for c in pushseq:
    var ok: bool
    (ok, s) = pushButton(c, d, s, code)
    echo c, " -> ", s
    assert ok
  assert s.pushed == 4

# testSequence("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A", "029A")

proc getMinPushes(d: Data, code: string, nrkpd: int): int =
  result = high(int)
  let s0 = getInitState(d, nrkpd)
  var v: Table[State, int]
  var hq: HeapQueue[StateAndCost]
  v[s0] = 0
  hq.push(StateAndCost(cost: 0, s: s0))
  while hq.len > 0:
    let sac = hq.pop()
    let (cost, s) = (sac.cost, sac.s)
    # echo ""
    # echo ""
    # echo s
    # echo "----"
    if s.pushed == 4:
      # echo cost
      return cost
    for c in "A<>^v":
      let costn = cost + 1
      var (ok, sn) = pushButton(c, d, s, code)
      # echo c, " -> ", sn
      if ok:
        if v.contains(sn):
          if costn >= v[sn]:
            continue
        v[sn] = costn
        hq.push(StateAndCost(cost: costn, s: sn))

assert getMinPushes(getInput("ex0.txt"), "029A", 2) == 68

proc getComplexity(fname: string, nrkpd: int): int =
  let d = getInput(fname)
  for code in d.codes:
    let cint = parseInt(code[0..2])
    let minp = getMinPushes(d, code, nrkpd)
    result += cint * minp

assert getComplexity("ex0.txt", 2) == 126384

proc getKeypadPossibilities(d: Data, code: string): seq[string] =
  result = @[]
  var sqs: seq[seq[string]]
  var cf = 'A'
  for ct in code:
    # echo d.npms[(cf, ct)]
    sqs.add(d.npms[(cf, ct)])
    cf = ct
  for i in 0..<sqs[0].len:
    for j in 0..<sqs[1].len:
      for k in 0..<sqs[2].len:
        for l in 0..<sqs[3].len:
          var s = sqs[0][i] & sqs[1][j] & sqs[2][k] & sqs[3][l]
          result.add(s)

type
  CacheElement = object
    l, r: char
    depth: int
type Cache = Table[CacheElement, int]

proc getMinKeyPadPushes(d: Data, l, r: char, depth: int,
    cache: var Cache): int =
  let ce = CacheElement(l: l, r: r, depth: depth)
  if cache.contains(ce):
    return cache[ce]
  if depth == 1:
    result = d.dpms[(l, r)][0].len
  else:
    result = high(int)
    for sq in d.dpms[(l, r)]:
      var count = 0
      for i in 0..<sq.len:
        let rhs = sq[i]
        var lhs = 'A'
        if i != 0:
          lhs = sq[i-1]
        count += getMinKeyPadPushes(d, lhs, rhs, depth - 1, cache)
      result = min(result, count)
  cache[ce] = result

proc getMinPushes2ForCand(d: Data, code: string, s: string, depth: int,
    cache: var Cache): int =
  for i in 0..<s.len:
    let rhs = s[i]
    var lhs = 'A'
    if i != 0:
      lhs = s[i-1]
    result += getMinKeyPadPushes(d, lhs, rhs, depth, cache)

proc getMinPushes2(d: Data, code: string, depth: int, cache: var Cache): int =
  let cands = getKeypadPossibilities(d, code)
  # echo cands
  result = high(int)
  for cand in cands:
    result = min(result, getMinPushes2ForCand(d, code, cand, depth, cache))

proc getComplexity2(fname: string, nrkpd: int): int =
  let d = getInput(fname)
  var cache: Cache
  for code in d.codes:
    let cint = parseInt(code[0..2])
    let minp = getMinPushes2(d, code, nrkpd, cache)
    result += cint * minp

assert getComplexity2("ex0.txt", 2) == 126384

proc part1(fname: string): int =
  return getComplexity(fname, 2)

proc part2(fname: string): int =
  return getComplexity2(fname, 25)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
