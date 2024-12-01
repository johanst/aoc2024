import strutils
import algorithm

proc getInput(fname: string): (seq[int], seq[int]) =
  var a: seq[int] = @[]
  var b: seq[int] = @[]
  for line in lines(fname):
    let w = line.strip().splitWhitespace()
    a.add(parseInt(w[0]))
    b.add(parseInt(w[1]))
  return (a, b)

proc part1(fname: string): int =
  var (a, b) = getInput(fname)
  sort(a)
  sort(b)
  result = 0
  for idx in 0..<len(a):
    result += abs(a[idx] - b[idx])

proc part2(fname: string): int =
  var (a, b) = getInput(fname)
  result = 0
  for n in b:
    if a.contains(n):
      result += n

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
