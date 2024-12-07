import strutils
import math

type
  Data = object
    res: int
    op: seq[int]

proc getInput(fname: string): seq[Data] =
  var d: seq[Data]
  for line in lines(fname):
    var dd: Data
    let w = line.strip().split(':')
    dd.res = parseInt(w[0])
    let wop = w[1].splitWhitespace()
    for op in wop:
      dd.op.add(parseInt(op))
    d.add(dd)
  return d

proc getCalibration(d: Data): int =
  let n = 2 ^ (d.op.len - 1)
  for i in 0..<n:
    var res = d.op[0]
    for j in 0..<d.op.len-1:
      if ((2 ^ j) and i) != 0:
        res *= d.op[j+1]
      else:
        res += d.op[j+1]
      if res > d.res:
        break
    if res == d.res:
      echo "*+  :", d.res, " ", d.op
      return d.res
  return 0

let exData = getInput("ex0.txt")
assert getCalibration(Data(res: 190, op: @[10, 19])) == 190

proc getCalibrationSum(fname: string): int =
  let d = getInput(fname)
  for dd in d:
    result += getCalibration(dd)

assert getCalibrationSum("ex0.txt") == 3749

proc concatInt(a, b: int): int =
  var bb = b
  var m = 1
  while bb > 0:
    bb = bb div 10
    m *= 10
  return a * m + b

assert concatInt(123, 45) == 12345

proc printOps(d: Data, n: int) =
  var s: seq[string]
  s.add(intToStr(d.op[0]))
  for j in 0..<d.op.len-1:
    let optype = ((n shr (2 * j)) and 3)
    case optype
    of 0:
      s.add("*")
    of 1:
      s.add("+")
    of 2:
      s.add("||")
    else:
      echo "******** invalid optype ", optype, " n=", n, " j=", j, " s=", s
      assert false
    s.add(intToStr(d.op[j]))
  let st = s.join(" ")
  echo "    -> ", st

proc getCalibration2(d: Data): int =
  let n = 4 ^ d.op.len
  for i in 0..<n:
    # echo "--- ", i, " ---- "
    var res = d.op[0]
    for j in 0..<d.op.len-1:
      let optype = ((i shr (2 * j)) and 3)
      case optype
      of 0:
        # echo "*"
        res *= d.op[j+1]
      of 1:
        # echo "+"
        res += d.op[j+1]
      of 2:
        # echo "||"
        res = concatInt(res, d.op[j+1])
      else:
        res = 0
        break
      if res > d.res:
        break
    if res == d.res:
      echo "*+||:", d.res, " ", d.op
      printOps(d, i)
      return d.res
  return 0

assert getCalibration2(Data(res: 192, op: @[17, 8, 14])) == 192
assert getCalibration2(Data(res: 7290, op: @[6, 8, 6, 15])) == 7290

assert getCalibration2(Data(res: 577634740, op: @[4, 843, 8, 60, 86, 294, 1, 4,
    4])) == 577634740


proc getCalibrationSum2(fname: string): int =
  let d = getInput(fname)
  for dd in d:
    var c1 = getCalibration(dd)
    if c1 > 0:
      result += c1
    else:
      c1 = getCalibration2(dd)
      if c1 > 0:
        result += c1
      else:
        echo "----:", dd.res, " ", dd.op

assert getCalibrationSum2("ex0.txt") == 11387

proc part1(fname: string): int =
  return getCalibrationSum(fname)

# 426214138756653 wrong answer
proc part2(fname: string): int =
  return getCalibrationSum2(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
