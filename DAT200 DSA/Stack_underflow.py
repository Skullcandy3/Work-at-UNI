# Make a class for a list to show how stack underflow works
class StackUnderflowList:
    def __init__(self):
        self.items = []

    def is_empty(self):
        return len(self.items) == 0

    def push(self, item):
        self.items.append(item)

    def pop(self):
        if self.is_empty():
            raise IndexError("Stack Underflow: Attempting to pop from an empty stack")
        return self.items.pop()

    def peek(self):
        if self.is_empty():
            raise IndexError("Stack Underflow: Attempting to peek at an empty stack")
        return self.items[-1]
    
# Example usage
stack = StackUnderflowList()
try:
    stack.pop()
except IndexError as e:
    print(e)

try:
    stack.peek()
except IndexError as e:
    print(e)

stack.push(10)
print("Top element after push:", stack.peek())

try:
    stack.pop()
except IndexError as e:
    print(e)

print("Top element is now gone!")
try:
    stack.peek()
except IndexError as e: # Here we will get stack underflow as we peek into a empty stack! 
    print(e)