# In this task we will be learning and using more the Circular Linked List (Double linked list)
#Small note for self, the Double LL can go backwards and forwards (Normal LL cant do that ;( )
## Question 3 "Make a program that can swap with 'k' as index for how many times to swap list items" 

class Node:
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None


class Circle_LL:
    def __init__(self):
        self.head = None

    def insert(self, data):
        new_node = Node(data)
        if self.head is None:
            # First node points to itself
            self.head = new_node
            new_node.next = new_node
            new_node.prev = new_node
        else:
            # Insert at the end (before head)
            tail = self.head.prev
            tail.next = new_node
            new_node.prev = tail
            new_node.next = self.head
            self.head.prev = new_node

    def display(self):
        if not self.head:
            print("Empty list")
            return
        current = self.head
        while True:
            print(current.data, end=" <-> ")
            current = current.next
            if current == self.head:
                break
        print("(back to head)")

    def length(self):
        if not self.head:
            return 0
        count = 0
        current = self.head
        while True:
            count += 1
            current = current.next
            if current == self.head:
                break
        return count

    def swap_knodes(self, k):
        n = self.length()
        if k <= 0 or k > n // 2:
            print("Invalid K value")
            return

        # first pointer (head start)
        first = self.head
        # last pointer (head.prev is last node)
        last = self.head.prev

        # Swap data between first k and last k nodes
        for _ in range(k):
            first.data, last.data = last.data, first.data
            first = first.next
            last = last.prev

if __name__ == "__main__":
    cll = Circle_LL()
    for i in range(1, 9):
        cll.insert(i)
    print("Original list:")
    cll.display()
    cll.swap_knodes(3)
    print("List after swapping:")
    cll.display()