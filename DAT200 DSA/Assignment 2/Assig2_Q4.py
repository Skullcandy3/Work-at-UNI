# Make a to-do list program using linked lists!
## Question 4 "Make a to-do list program that has some cool features!"

class Node:
    def __init__(self, task):
        self.task = task
        self.next = None


class Task:
    def __init__(self, title, priority=3, due_date=None):
        self.title = title
        self.priority = priority  # 1 = Low, 2 = Medium, 3 = High
        self.due_date = due_date  # format: "YYYY-MM-DD" or None
        self.completed = False

    def mark_completed(self):
        self.completed = True

    def __str__(self):
        status = "Done" if self.completed else "Not done"
        due = self.due_date if self.due_date else "No due date"
        return f"{self.title} | Priority: {self.priority} | Due: {due} | {status}"


class LinkedList:
    def __init__(self):
        self.head = None

    def insert(self, task):
        new_node = Node(task)
        new_node.next = self.head
        self.head = new_node

    def remove(self, title):
        current = self.head
        prev = None
        while current:
            if current.task.title == title:
                if prev:
                    prev.next = current.next
                else:
                    self.head = current.next
                return True
            prev = current
            current = current.next
        return False

    def mark_completed(self, title):
        current = self.head
        while current:
            if current.task.title == title:
                current.task.mark_completed()
                return True
            current = current.next
        return False

    def display(self):
        if not self.head:
            print("No tasks in the list.")
            return
        current = self.head
        while current:
            print(current.task)
            current = current.next

    def sort_by_priority(self):
        if not self.head or not self.head.next:
            return

        # Convert linked list to a list
        tasks = []
        current = self.head
        while current:
            tasks.append(current.task)
            current = current.next

        # Sort the list by priority
        tasks.sort(key=lambda x: x.priority)

        # Rebuild the linked list
        self.head = None
        for task in tasks:
            self.insert(task)

if __name__ == "__main__":
    todo = LinkedList()
    todo.insert(Task("Walk the dog", priority=3, due_date="2025-09-02"))
    todo.insert(Task("Finish assignment", priority=1, due_date="2025-09-10"))
    todo.insert(Task("Buy groceries", priority=2, due_date="2025-09-05"))
    todo.insert(Task("Go for a run", priority=3))
    todo.insert(Task("Shave my beard", priority=2, due_date="2025-09-03"))

    print("To-Do List:")
    todo.display()

    print("\nMark 'Buy groceries' as completed")
    todo.mark_completed("Buy groceries")
    todo.display()

    print("\nRemove 'Go for a run'")
    todo.remove("Go for a run")
    todo.display()

    print("\nInsert 'Pay my bills'")
    todo.insert(Task("Pay my bills", priority=1, due_date="2025-09-15"))
    todo.display()

    print("\nSort tasks by priority")
    todo.sort_by_priority()
    todo.display()
