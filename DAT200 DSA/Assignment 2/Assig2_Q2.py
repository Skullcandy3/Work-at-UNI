# In this task we are going to deal with doubly linked list that can go next and prev
## Question 2 "Make a program that removes the duplicates from a circular linked list"

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
            # first node points to itself
            self.head = new_node
            new_node.next = new_node
            new_node.prev = new_node
        else:
            # insert at the end (before head)
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

    def remove_duplicates(self):
        if not self.head:
            return

        seen = set()
        current = self.head
        while True:
            if current.data in seen:
                # remove the current node
                current.prev.next = current.next
                current.next.prev = current.prev

                # if we're removing the head, move head forward
                if current == self.head:
                    self.head = current.next
            else:
                seen.add(current.data)

            current = current.next
            if current == self.head:
                break

if __name__ == "__main__":
    cll = Circle_LL()
    cll.insert(1)
    cll.insert(2)
    cll.insert(3)
    cll.insert(2)
    cll.insert(4)
    cll.insert(3)
    print("Original list:")
    cll.display()

    print("New list:")
    cll.remove_duplicates()
    cll.display()