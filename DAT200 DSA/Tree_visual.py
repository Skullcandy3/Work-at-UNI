import turtle

# -------------------------------
# Binary Tree Node Definition
# -------------------------------
class Node:
    def __init__(self, value, left=None, right=None):
        self.value = value
        self.left = left
        self.right = right

# -------------------------------
# Draw Tree Function
# -------------------------------
def draw_tree(t, node, x, y, dx, dy):
    """
    Recursively draw a binary tree using turtle graphics.
    t  : turtle object
    node: current Node
    x,y: coordinates of the node
    dx : horizontal distance to children
    dy : vertical distance to children
    """
    if node is None:
        return

    # Move turtle to node position without drawing
    t.penup()
    t.goto(x, y)
    t.pendown()

    # Draw the node as a circle
    t.fillcolor("lightblue")
    t.begin_fill()
    t.circle(20)
    t.end_fill()

    # Write the node value
    t.penup()
    t.goto(x, y+10)
    t.write(str(node.value), align="center", font=("Arial", 10, "bold"))

    # Draw left child
    if node.left:
        t.goto(x, y)  # bottom of current node
        t.pendown()
        t.goto(x - dx, y - dy + 15)  # line to child
        draw_tree(t, node.left, x - dx, y - dy, dx / 2, dy)

    # Draw right child
    if node.right:
        t.penup()
        t.goto(x, y)
        t.pendown()
        t.goto(x + dx, y - dy + 15)
        draw_tree(t, node.right, x + dx, y - dy, dx / 2, dy)

# -------------------------------
# Example Tree
# -------------------------------
#       A
#      / \
#     B   C
#    / \   \
#   D   E   F
#          / \
#         G   H
root = Node("A",
        Node("B", Node("D"), Node("E")),
        Node("C", None, Node("F", Node("G"), Node("H"))))

root2 = Node("A",
        Node("B", Node("D"), Node("E")),
        Node("C", Node("G"), Node("F", None, Node("H"))))
# -------------------------------
# Turtle Setup
# -------------------------------
screen = turtle.Screen()
screen.title("Binary Tree Visualization")
screen.setup(width=1000, height=600)

t = turtle.Turtle()
t.speed(0)  # fastest
t.hideturtle()

# Draw the tree starting from root
#draw_tree(t, root, 0, 200, 200, 100)    # Example Unbalanced tree
draw_tree(t, root2, 0, 200, 200, 100)    # Example Balanced tree
# Keep window open until clicked
screen.mainloop()

# -------------------------------
# Example Balanced Tree
# -------------------------------
#       A
#      / \
#     B    C
#    / \   /\
#   D   E G  F
#             \
#              H