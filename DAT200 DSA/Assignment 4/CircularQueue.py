# Create a circular queue using array best way to implement a circular queue instead of using a linked list
class CircularQueue:
    def __init__(self, capacity=10):
        self.capacity = capacity
        self.items = [None] * capacity
        self.front = 0
        self.rear = 0
        self.size = 0

    def is_empty(self):
        return self.size == 0

    def is_full(self):
        return self.size == self.capacity

    def enqueue(self, item):
        if self.is_full():
            raise OverflowError("enqueue to full circular queue")
        else:
            self.items[self.rear] = item
            self.rear = (self.rear + 1) % self.capacity
            self.size += 1

    def dequeue(self):
        if self.is_empty():
            raise IndexError("dequeue from empty circular queue")
        else:
            item = self.items[self.front]
            self.items[self.front] = None
            self.front = (self.front + 1) % self.capacity
            self.size -= 1
            return item

    def peek(self):
        if self.is_empty():
            raise IndexError("peek from empty circular queue")
        else:
            return self.items[self.front]

    def current_size(self):
        return self.size
    
MyCircularQueue = CircularQueue(10)
for i in range(1, 11):
    MyCircularQueue.enqueue(i)
print(MyCircularQueue.current_size())
print(MyCircularQueue.is_empty())
print(MyCircularQueue.peek())
MyCircularQueue.enqueue(11)  # This will raise an OverflowError