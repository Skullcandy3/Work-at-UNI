# Create a queue using array best way using this compared to linked list to implement a queue

class Queue:
    def __init__(self):
        self.items = []

    def is_empty(self):
        return len(self.items) == 0
    
    def is_full(self):
        return len(self.items) == 10

    def enqueue(self, item):
        if self.is_full():
            raise OverflowError("enqueue to full queue")
        else:
            self.items.append(item)

    def dequeue(self):
        if not self.is_empty():
            return self.items.pop(0)
        else:
            raise IndexError("dequeue from empty queue")

    def front(self):
        if not self.is_empty():
            return self.items[0]
        else:
            raise IndexError("front from empty queue")

    def size(self):
        return len(self.items)
    
MyQueue = Queue()
for i in range(1, 10):
    MyQueue.enqueue(i)

print(MyQueue.size())
print(MyQueue.is_empty())
print(MyQueue.front())