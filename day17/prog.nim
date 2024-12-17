import math

type
  Data = object
    a0, b0, c0: int
    p: seq[int]

proc getExample(): Data =
  var d: Data
  d.a0 = 729
  d.b0 = 0
  d.c0 = 0
  d.p = @[0, 1, 5, 4, 3, 0]
  return d

proc getInput(): Data =
  var d: Data
  d.a0 = 30878003
  d.b0 = 0
  d.c0 = 0
  d.p = @[2, 4, 1, 2, 7, 5, 0, 3, 4, 7, 1, 7, 5, 5, 3, 0]
  return d

type
  State = object
    a, b, c, ip: int
    output: seq[int]

proc getInitState(d: Data): State =
  var s: State
  s.a = d.a0
  s.b = d.b0
  s.c = d.c0
  return s

proc ld(s: State, op: int): int =
  if op < 4:
    return op
  case op
  of 4:
    return s.a
  of 5:
    return s.b
  of 6:
    return s.c
  else:
    assert false, "Illegal operand"

proc step(s: var State, d: Data): bool =
  if s.ip >= d.p.len:
    return false
  let code = d.p[s.ip]
  var dip = 2
  case code
  of 0:
    # adv
    let opc = s.ld(d.p[s.ip+1])
    s.a = s.a div (2 ^ opc)
  of 1:
    # bxl
    let opl = d.p[s.ip+1]
    s.b = s.b xor opl
  of 2:
    # bst
    let opc = s.ld(d.p[s.ip+1])
    s.b = opc and 7
  of 3:
    # jnz
    let opl = d.p[s.ip+1]
    if s.a != 0:
      s.ip = opl
      dip = 0
  of 4:
    # bxc
    s.b = s.b xor s.c
  of 5:
    # out
    let opc = s.ld(d.p[s.ip+1])
    s.output.add(opc and 7)
  of 6:
    # bdv
    let opc = s.ld(d.p[s.ip+1])
    s.b = s.a div (2 ^ opc)
  of 7:
    # cdv
    let opc = s.ld(d.p[s.ip+1])
    s.c = s.a div (2 ^ opc)
  else:
    assert false, "Illegal program"
  s.ip += dip
  return true

proc run(d: Data): seq[int] =
  var s = d.getInitState()
  while step(s, d):
    discard
  return s.output

assert run(getExample()) == @[4, 6, 3, 5, 6, 3, 5, 2, 1, 0]

proc run2(d: Data): int =
  # eventually just type the correct number here
  var count = 0
  while true:
    var s = d.getInitState()
    s.a = count
    while step(s, d) and (s.output.len <= d.p.len):
      if s.output.len == 0:
        continue
      elif s.output[s.output.len - 1] != d.p[s.output.len - 1]:
        break
    if d.p == s.output:
      return count
    count += 1

proc getExample2(): Data =
  var d: Data
  d.a0 = 2024
  d.b0 = 0
  d.c0 = 0
  d.p = @[0, 3, 5, 4, 3, 0]
  return d

assert run2(getExample2()) == 117440

proc runOne(a: int, d: Data): State =
  var s: State
  s.a = a
  while s.ip != 14:
    assert step(s, d)
  return s

proc getLargeNumber(a: int, d: Data, depth: int): int =
  for aa in 0..7:
    let aaa = a shl 3 + aa
    let s = runOne(a = aaa, d)
    if s.output[0] != d.p[15 - depth]:
      continue
    if depth == 15:
      return aaa
    let ac = getLargeNumber(aaa, d, depth + 1)
    if ac != -1:
      return ac
  return -1

proc part1(fname: string): seq[int] =
  return run(getInput())

proc part2(fname: string): int =
  return getLargeNumber(a = 0, d = getInput(), depth = 0)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
