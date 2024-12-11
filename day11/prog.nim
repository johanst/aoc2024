import strutils
import math
import sets
import deques
import tables

let data_input = [2u64, 77706, 5847, 9258441, 0, 741, 883933, 12]
let ex_input = [125u64, 17]
var tens: seq[uint] = @[]

proc initTens() =
  var ten: uint = 1
  for i in 1..19:
    ten *= 10
    tens.add(ten)
initTens()

proc getNumDigits(n: uint64): int =
  for idx, nmax in tens:
    if n < nmax:
      return idx + 1
  return 20

assert getNumDigits(10) == 2
assert getNumDigits(999) == 3

proc splitNum(n: uint64, nd: int): (uint64, uint64) =
  let lhs: uint64 = n div (10u64 ^ (nd div 2))
  let rhs: uint64 = n - lhs * (10u64 ^ (nd div 2))
  return (lhs, rhs)

assert splitNum(17, getNumDigits(17)) == (1u64, 7u64)

proc blink(d: openArray[uint64]): seq[uint64] =
  var s: seq[uint64] = @d
  for i in 1..25:
    var sn: seq[uint64]
    for n in s:
      let nd = getNumDigits(n)
      if n == 0:
        sn.add(1)
      elif nd mod 2 == 0:
        let (lhs, rhs) = splitNum(n, nd)
        sn.add(lhs)
        sn.add(rhs)
      else:
        sn.add(2024u64 * n)
    s = sn
    # echo "blink ", i
    # echo s
  return s

assert blink(ex_input).len == 55312

type Data = object
  count: uint64
  sn: seq[uint64]

proc blink75(d: openArray[uint64]): uint64 =
  var b25h: Table[uint64, seq[uint64]]
  for n in d:
    b25h[n] = blink([n])
  var b50h: Table[uint64, Data]
  for k, v in b25h:
    for n in v:
      if b50h.contains(n):
        b50h[n].count += 1
      else:
        b50h[n] = Data(count: 1, sn: blink([n]))
  var b75h: Table[uint64, Data]
  for k, v in b50h:
    for n in v.sn:
      if b75h.contains(n):
        b75h[n].count += v.count
      else:
        b75h[n] = Data(count: v.count, sn: blink([n]))
  for v in b75h.values:
    result += v.count * uint64(v.sn.len)

proc part1(d: openArray[uint64]): int =
  return blink(d).len

proc part2(d: openArray[uint64]): uint64 =
  return blink75(d)

echo "Part1: ", part1(data_input)
echo "Part2: ", part2(data_input)
