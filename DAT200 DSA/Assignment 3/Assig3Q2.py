# Chess for queens that cant attack each other as a matrix

def print_board(board):
    for row in board:
        print(" ".join("Q" if cell else "." for cell in row))
    print()

def is_safe(board, row, col):
    for i in range(col):
        if board[row][i]:
            return False
    for i, j in zip(range(row, -1, -1), range(col, -1, -1)):
        if board[i][j]:
            return False
    for i, j in zip(range(row, len(board)), range(col, -1, -1)):
        if board[i][j]:
            return False
    return True

def solve_n_queens_util(board, col, solutions):
    if col >= len(board):
        # Deep copy the board to store the solution
        solutions.append([row[:] for row in board])
        return

    for i in range(len(board)):
        if is_safe(board, i, col):
            board[i][col] = 1
            solve_n_queens_util(board, col + 1, solutions)
            board[i][col] = 0  # Backtrack

def solve_n_queens(n):
    board = [[0 for _ in range(n)] for _ in range(n)]
    solutions = []
    solve_n_queens_util(board, 0, solutions)

    if not solutions:
        print("Solution does not exist")
        return False

    print(f"Total solutions: {len(solutions)}\n")
    for idx, sol in enumerate(solutions, 1):
        print(f"Solution {idx}:")
        print_board(sol)
    return True

# Test the function with a 5x5 board
solve_n_queens(5)