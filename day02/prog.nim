import strutils

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
  let ls = getInput(fname)
  result = 0
  for l in ls:
    if isSafe(l):
      result += 1
    else:
      # Very inefficient but works for this data...
      for idx in 0..<len(l):
        var nl = l
        nl.delete(idx)
        if isSafe(nl):
          result += 1
          break

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
