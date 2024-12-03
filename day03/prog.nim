import strutils
import re

proc getInput(fname: string): seq[string] =
  result = @[]
  for line in lines(fname):
    result.add(line.strip())

proc getInputAllLines(fname: string): string =
  let ls = getInput(fname)
  return ls.join("")

proc getMul(s: string): int =
  result = 0
  let pattern = re"mul\(\d+,\d+\)"
  let matches = findAll(s, pattern)
  for m in matches:
    let w = m.split(",")
    let l = parseInt(w[0][4..^1])
    let r = parseInt(w[1][0..^2])
    result += l * r

assert getMul("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))") == 161

proc getMulWithDoDont(s: string): int =
  result = 0
  let p = re"mul\(\d+,\d+\)"
  let dop = re"do(?!n't)\(\)"
  let dontp = re"don't\(\)"
  var dopos = 0
  var dontpos = 0
  var pos = 0
  var pose = 0
  (pos, pose) = findBounds(s, p, pos)
  while pos != -1:
    while dontpos < pos:
      let n = find(s, dontp, dontpos+1)
      if n > pos or n == -1:
        break
      else:
        dontpos = n
    while dopos < pos:
      let n = find(s, dop, dopos+1)
      if n > pos or n == -1:
        break
      else:
        dopos = n
    # echo "pos=", pos, " dontpos=", dontpos, " dopos=", dopos
    if dopos >= dontpos:
      let w = s[pos..pose].split(",")
      let l = parseInt(w[0][4..^1])
      let r = parseInt(w[1][0..^2])
      result += l * r
    (pos, pose) = findBounds(s, p, pos + 1)

assert getMulWithDoDont("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))") == 48

proc part1(fname: string): int =
  let s = getInputAllLines(fname)
  return getMul(s)

proc part2(fname: string): int =
  let s = getInputAllLines(fname)
  return getMulWithDoDont(s)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
