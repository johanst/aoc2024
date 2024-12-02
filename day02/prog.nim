import strutils
import algorithm

proc getInput(fname: string): seq[seq[int]] =
  result = @[]
  for line in lines(fname):
    let w = line.strip().splitWhitespace()
    var l: seq[int] = @[]
    for n in w:
      l.add(parseInt(n))
    result.add(l)

proc isSafe(ls: openArray[int]): bool =
  var prev = ls[0]
  var nc, pc = false
  for l in ls[1..^1]:
    let diff = l - prev
    if abs(diff) < 1 or abs(diff) > 3:
      return false
    if diff > 0:
      pc = true
    elif diff < 0:
      nc = true
    else:
      return false
    if pc and nc:
      return false
    prev = l
  return true

assert isSafe([7, 6, 4, 2, 1])
assert not isSafe([1, 2, 7, 8, 9])

proc part1(fname: string): int =
  let ls = getInput(fname)
  result = 0
  for l in ls:
    if isSafe(l):
      result += 1

proc part2(fname: string): int =
  return 0
  # var (a, b) = getInput(fname)
  # result = 0
  # for n in b:
  #   if a.contains(n):
  #     result += n

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
