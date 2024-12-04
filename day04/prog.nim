import strutils
import algorithm

proc getInput(fname: string): seq[string] =
  result = @[]
  for line in lines(fname):
    result.add(line.strip())

proc getNumXmas(fname: string): int =
  result = 0
  let array = getInput(fname)
  let size = array.len
  assert array[0].len == size
  # horizontal
  for l in array:
    result += count(l, "XMAS")
    result += count(l, "SAMX")
  # vertical
  for c in 0..<size:
    var s = ""
    for r in 0..<size:
      s.add(array[r][c])
    result += count(s, "XMAS")
    result += count(s, "SAMX")
  # +45 degrees
  for cstart in 0..size*2-2:
    var s = ""
    var r = 0
    var c = cstart
    for _ in 0..<size:
      if r in 0..size-1 and c in 0..size-1:
        s.add(array[r][c])
      r += 1
      c -= 1
    result += count(s, "XMAS")
    result += count(s, "SAMX")
    # echo s
  # -45 degrees
  for rstart in countdown(size-1, -size+1):
    var s = ""
    var r = rstart
    var c = 0
    for _ in 0..<size:
      # echo r, " ", c
      if r in 0..size-1 and c in 0..size-1:
        s.add(array[r][c])
      r += 1
      c += 1
    # echo s
    result += count(s, "XMAS")
    result += count(s, "SAMX")

assert getNumXmas("ex0.txt") == 18

proc getNumXmas2(fname: string): int =
  let array = getInput(fname)
  let size = array.len
  assert array[0].len == size
  for r in 1..<size-1:
    for c in 1..<size-1:
      if array[r][c] != 'A':
        continue
      var x1, x2: seq[char]
      x1.add(array[r-1][c-1])
      x1.add(array[r+1][c+1])
      x2.add(array[r-1][c+1])
      x2.add(array[r+1][c-1])
      sort(x1)
      sort(x2)
      if x1.join() == "MS" and x2.join == "MS":
        result += 1

assert getNumXmas2("ex0.txt") == 9

proc part1(fname: string): int =
  return getNumXmas(fname)

proc part2(fname: string): int =
  return getNumXmas2(fname)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
