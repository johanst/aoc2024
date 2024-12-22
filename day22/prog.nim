import strutils
import sequtils
import math
import re
import tables
import sets
import algorithm
import heapqueue
import deques

type
  Data = object
    secrets: seq[int]

proc getInput(fname: string): Data =
  var d: Data
  for line in lines(fname):
    d.secrets.add(parseInt(line.strip()))
  return d

proc printStuff() =
  let d = getInput("ex0.txt")
  echo d

# printStuff()

# Generates all numbers 1..16777215
proc nextSecret(s: int): int =
  var s1 = s * 64
  s1 = s1 xor s
  s1 = s1 mod 16777216
  var s2 = s1 div 32
  s2 = s2 xor s1
  s2 = s2 mod 16777216
  var s3 = s2 * 2048
  s3 = s3 xor s2
  s3 = s3 mod 16777216
  return s3

proc testSequence() =
  var s = 123
  for i in 0..<10:
    s = nextSecret(s)
    echo s

# testSequence()

proc get2000Secret(s: int): int =
  result = s
  for i in 1..2000:
    result = nextSecret(result)

proc getSum2000Secret(fname: string): int =
  let d = getInput(fname)
  for n in d.secrets:
    result += get2000Secret(n)

assert getSum2000Secret("ex0.txt") == 37327623

proc findSeq() =
  let d = getInput("input.txt")
  var s = d.secrets[4]
  var sq: Table[int, int]
  for i in 0..<16777216:
    sq[s] = i
    s = nextSecret(s)
    if sq.contains(s):
      echo "Number ", s, " seen at both ", i + 1, " and ", sq[s]
      break

findSeq()

proc part1(fname: string): int =
  return getSum2000Secret(fname)

proc part2(fname: string): int =
  return 0
  # return getComplexity(fname, 25)

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
