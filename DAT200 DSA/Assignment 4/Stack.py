# Create a stack using array best way to implement a stack instead of using a linked list

class Stack:
    def __init__(self):
        self.items = []

    def is_empty(self):
        return len(self.items) == 0
    
    def is_full(self):
        return len(self.items) == 10

    def push(self, item):
        if self.is_full():
            raise OverflowError("push to full stack")
        else:
            self.items.append(item)

    def pop(self):
        if not self.is_empty():
            return self.items.pop()
        else:
            raise IndexError("pop from empty stack")

    def peek(self):
        if not self.is_empty():
            return self.items[-1]
        else:
            raise IndexError("peek from empty stack")

    def size(self):
        return len(self.items)

#MyStack = Stack()
#for i in range(1, 20):
#    MyStack.push(i)
#print(MyStack.size())
#print(MyStack.is_empty())
def DC(a, n):
    if n==1:
        return a
    if n % 2 == 0: 
        return (DC(a, n//2) * DC(a, n//2))
    return (a*DC(a, n-1))

#print(DC(2,6))

# DC(2,6) = 64
# DC(2,3) * DC(2,3) = 8*8 = 64
# 2 * DC(2,2) = 2 * 4 = 8
# DC(2,1) * DC(2,1) = 2*1 * 2*1 = 4
