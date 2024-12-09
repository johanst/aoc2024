import strutils
import math
import tables
import algorithm

proc getInput(fname: string): seq[int] =
  result = @[]
  let file = open(fname)
  defer: file.close()
  let line = file.readLine().strip()
  for c in line:
    result.add(ord(c) - ord('0'))

proc sortFiles(fname: string): int =
  let d = getInput(fname)
  var fidx, nfblocks = 0
  var isFile = true
  var fmap: seq[int]
  for cnt in d:
    var n = -1
    if isFile:
      n = fidx
      nfblocks += cnt
      fidx += 1
    for _ in 0..<cnt:
      fmap.add(n)
    isFile = not isFile

  var pos = 0
  while fmap.len != nfblocks:
    while fmap[pos] == -1:
      fmap[pos] = fmap.pop()
    pos += 1

  for i, n in fmap:
    result += i * n

assert sortFiles("ex0.txt") == 1928

proc free(pos: int, size: int, fmap: var seq[int], fbegs: var seq[int],
    fbegmap: var Table[int, int], fendmap: var Table[int, int]) =
  for i in pos..<pos+size:
    fmap[i] = -1
  var fbeg = pos
  var fbegOld = fbeg
  var fend = pos + size
  var fsize = size
  # merge to left ?
  if fendmap.contains(fbeg):
    let lsize = fendmap[fbeg]
    fendmap.del(fbeg)
    fbegmap.del(fbeg - lsize)
    let delIdx = binarySearch(fbegs, fbeg - lsize)
    if delIdx >= 0:
      fbegs.delete(delIdx)
    fsize += lsize
    fbeg -= lsize
  # merge to right ?
  if fbegmap.contains(fend):
    let rsize = fbegmap[fend]
    fbegmap.del(fend)
    fendmap.del(fend + rsize)
    let delIdx = binarySearch(fbegs, fend)
    if delIdx >= 0:
      fbegs.delete(delIdx)
    fsize += rsize
    fend += rsize
  fbegmap[fbeg] = fsize
  fendmap[fend] = fsize
  if fbeg != fbegOld:
    let insIdx = fbegs.lowerBound(fbeg)
    fbegs.insert(fbeg, insIdx)

proc insert(fidx: int, size: int, fmap: var seq[int], fbegs: var seq[int],
            fbegmap: var Table[int, int], fendmap: var Table[int, int],
                maxpos: int): bool =
  var pos = -1
  for fbeg in fbegs:
    if fbeg > maxpos:
      return false
    if fbegmap[fbeg] >= size:
      # it fits
      pos = fbeg
      break
  if pos == -1:
    return false

  for i in pos..<pos+size:
    fmap[i] = fidx

  let oldFreeSize = fbegmap[pos]
  let delIdx = binarySearch(fbegs, pos)
  if oldFreeSize == size:
    # remove all
    fbegs.delete(delIdx)
    fbegmap.del(pos)
    fendmap.del(pos+oldFreeSize)
  else:
    let newSize = oldFreeSize - size
    let newPos = pos + size
    fbegs[delIdx] = newPos
    fendmap[pos+oldFreeSize] = newSize
    fbegmap.del(pos)
    fbegmap[newPos] = newSize
  return true

proc printseq(fmap: seq[int]) =
  var s = "  "
  for n in fmap:
    if n != -1:
      s.add(intToStr(n))
    else:
      s.add('.')
  echo s

proc sortFiles2(fname: string): int =
  let d = getInput(fname)
  var fidx = 0
  var isFile = true
  var fmap: seq[int] # complete block layout
  var fpos: seq[tuple[pos: int, size: int]] # position, size of specific fidx in fmap
  var fbegs: seq[int] # sorted keys of fbegmap (because table is not sorted....)
  var fbegmap: Table[int, int] # pos -> size of free mem area
  var fendmap: Table[int, int] # pos + size -> size of free mem area
  var bpos = 0
  for cnt in d:
    var n = -1
    if isFile:
      fpos.add((bpos, cnt))
      n = fidx
      fidx += 1
    elif cnt > 0:
      fbegs.add(bpos)
      fbegmap[bpos] = cnt
      fendmap[bpos + cnt] = cnt
    for _ in 0..<cnt:
      fmap.add(n)
    bpos += cnt
    isFile = not isFile

  for fidx in countdown(fpos.len - 1, 0):
    let (pos, size) = fpos[fidx]
    # echo "--- fidx=", fidx, " pos=", pos, " size=", size
    # echo "fbegmap=", fbegmap
    # echo "fbegs=", fbegs
    # echo "fendmap=", fendmap
    # echo "fmap=", fmap
    # echo "fpos=", fpos
    # echo "  insert ->"
    if insert(fidx, size, fmap, fbegs, fbegmap, fendmap, pos):
      # echo "  free ->"
      free(pos, size, fmap, fbegs, fbegmap, fendmap)
    # printseq(fmap)

  for i, n in fmap:
    if n != -1:
      result += i * n

assert sortFiles2("ex0.txt") == 2858

proc part1(fname: string): int =
  return sortFiles("input.txt")

proc part2(fname: string): int =
  return sortFiles2("input.txt")

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
