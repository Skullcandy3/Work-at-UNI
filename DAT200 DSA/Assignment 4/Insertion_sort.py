# LEts make a code for insertion sort with print per pass of the function
def insertion_sort(arr):
    # Traverse through 1 to len(arr)
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        # Move elements of arr[0..i-1], that are greater than key,
        # to one position ahead of their current position
        while j >= 0 and key < arr[j]:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
        print(f"Pass {i}: {arr}")  # Print the array after each pass
    return arr  

# Example usage
arr = [100, 22, 5, 36, 999, 12]
insertion_sort(arr)
print("Sorted array is:", arr)

arr2 = [-20, -16, 8, -3, 9, 14, 1, -8, 17, 5]
insertion_sort(arr2)
print("Sorted array is:", arr2)