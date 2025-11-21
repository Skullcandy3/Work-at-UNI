# In this task we are going to deal with linked lists
## Question 1 "Make a max and min function for a cool linked list"

class LinkedList:
    def __init__(self):
        self.head = None

    def insert(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node

    def display(self):
        current = self.head
        while current:
            print(current.data, end=" -> ")
            current = current.next
        print("None")

    def max(self):
        if not self.head:
            return None
        max_value = self.head.data
        current = self.head
        while current:
            if current.data > max_value:
                max_value = current.data
            current = current.next
        return max_value
    
    def min(self):
        if not self.head:
            return None
        min_value = self.head.data
        current = self.head
        while current:
            if current.data < min_value:
                min_value = current.data
            current = current.next
        return min_value

class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

if __name__ == "__main__":
    LL = LinkedList()
    LL.insert(5)
    LL.insert(10)
    LL.insert(15)
    LL.display()
    print("Max:", LL.max())
    print("Min:", LL.min())

