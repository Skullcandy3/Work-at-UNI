#In this program we are going to take a look a recursion and plaidrom words!
# Iterative
def is_palindrome_iterative(s):
    left, right = 0, len(s) - 1
    while left < right:
        if s[left] != s[right]:
            return False
        left += 1
        right -= 1
    return True

# Recursive
def is_palindrome(s):
    # Base case: if the string is empty or has one character, it's a palindrome
    if len(s) <= 1:
        return True
    
    # Check the first and last characters
    if s[0] != s[-1]:
        return False
    # Recursive case: check the substring without the first and last characters
    # Runs until the base case is reached
    return is_palindrome(s[1:-1])

# Test the function
print(is_palindrome("racecar"))  # True
print(is_palindrome("hello"))    # False

# Test the iterative function
print(is_palindrome_iterative("racecar"))  # True
print(is_palindrome_iterative("hello"))    # False
