import tkinter as tk
from tkinter import ttk

# Define a simple tree data structure
class TreeNode:
    def __init__(self, name):
        self.name = name
        self.children = []

    def add_child(self, child):
        self.children.append(child)
    
    def remove_child(self, child):
        self.children.remove(child)

    def get_children(self):
        return self.children
    
    def get_parent(self, root, target):
        if root is target:
            return "This is root"
        for child in root.children:
            if child is target:
                return root
            parent = self.get_parent(child, target)
            if parent:
                return parent
        return "No parent found!"
        
# Create a sample tree
def create_sample_tree():
    root = TreeNode("Root")
    child1 = TreeNode("Child 1")
    child2 = TreeNode("Child 2")
    child3 = TreeNode("Child 3")

    child1.add_child(TreeNode("Grandchild 1.1"))
    child1.add_child(TreeNode("Grandchild 1.2"))

    child2.add_child(TreeNode("Grandchild 2.1"))

    root.add_child(child1)
    root.add_child(child2)
    root.add_child(child3)

    return root

# Populate the Treeview widget with the tree data
def populate_treeview(treeview, parent, node):
    tree_id = treeview.insert(parent, "end", text=node.name)
    for child in node.get_children():
        populate_treeview(treeview, tree_id, child)

# Create the GUI
def create_gui(tree_root):
    root = tk.Tk()
    root.title("Tree Data Structure with Tkinter")

    # Create a Treeview widget
    treeview = ttk.Treeview(root)
    treeview.pack(fill="both", expand=True)

    # Populate the Treeview with the tree data
    populate_treeview(treeview, "", tree_root)

    root.mainloop()
    
# Main execution
if __name__ == "__main__":
    tree_root = create_sample_tree()
    create_gui(tree_root)
