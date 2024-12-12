# Some day I am going to need this

import heapqueue

type MaxHeapItem[T] = object
  value: T

proc `<`[T](a, b: MaxHeapItem[T]): bool =
  a.value > b.value

var maxHeap = initHeapQueue[MaxHeapItem[int]]()

maxHeap.push(MaxHeapItem[int](value: 5))
maxHeap.push(MaxHeapItem[int](value: 3))
maxHeap.push(MaxHeapItem[int](value: 9))
maxHeap.push(MaxHeapItem[int](value: 1))

echo maxHeap[0].value # Output: 9 (max element)
echo maxHeap.pop().value # Output: 9 (removes and returns max element)
echo maxHeap[0].value # Output: 5 (new max element)

var maxHeap2: HeapQueue[MaxHeapItem[string]]
maxHeap2.push(MaxHeapItem[string](value: "hej"))
maxHeap2.push(MaxHeapItem[string](value: "ho"))
echo maxHeap2.pop().value
