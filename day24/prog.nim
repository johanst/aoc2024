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
  Operator = enum
    AND
    OR
    XOR

type
  Operation = object
    a, b, c: int
    op: Operator

type
  Data = object
    vseq: seq[(string, int)] # name, initval
    idx2v: Table[int, string]
    v2idx: Table[string, int]
    ops: seq[Operation]

proc opId(d: Data, idx: int): string =
  return d.vseq[idx][0]

proc addVal(d: var Data, id: string, initVal: int) =
  if not d.v2idx.contains(id):
    d.vseq.add((id, initVal))
    d.v2idx[id] = d.vseq.len - 1

proc getInput(fname: string): Data =
  var d: Data
  var ops: seq[seq[string]]
  var reading_ops = false
  for line in lines(fname):
    let l = line.strip()
    let w = l.splitWhitespace()
    if not reading_ops:
      if l.len == 0:
        reading_ops = true
      else:
        d.addVal(w[0][0..2], parseInt(w[1]))
    else:
      d.addVal(w[0], 0)
      d.addVal(w[2], 0)
      d.addVal(w[4], 0)
      ops.add(w)
  for w in ops:
    var op: Operator
    if w[1] == "AND":
      op = AND
    elif w[1] == "OR":
      op = OR
    elif w[1] == "XOR":
      op = XOR
    else:
      assert false, "Illegal operation"
    d.ops.add(Operation(
      a: d.v2idx[w[0]], b: d.v2idx[w[2]], c: d.v2idx[w[4]], op: op))
  for k, v in d.v2idx:
    d.idx2v[v] = k
  return d

proc printStuff() =
  let d = getInput("ex0.txt")
  echo d.vseq
  echo d.vseq.len
  for k, v in d.v2idx:
    echo k, " -> ", v
  echo d.vseq
  for op in d.ops:
    echo d.opId(op.a), " ", op.op, " ", d.opId(op.b), " -> ", d.opId(op.c)

printStuff()

proc part1(fname: string): int =
  return 0

proc part2(fname: string): int =
  return 0

echo "Part1: ", part1("input.txt")
echo "Part2: ", part2("input.txt")
