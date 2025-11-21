# Lets make a code for quick sort with print per partitioning of the function
def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    else:
        pivot = arr[-1]  # We pick the pivot as last element
        left = [x for x in arr if x < pivot]
        middle = [x for x in arr if x == pivot]
        right = [x for x in arr if x > pivot]
        sorted_arr = quick_sort(left) + middle + quick_sort(right)
        #print(f"Partitioning with pivot {pivot}: {sorted_arr}")  # Print the array after each partitioning
        return sorted_arr
    
# Example usage
arr = [1,5,3,4,2,5,8,2,6,9]
sorted_arr = quick_sort(arr)
print("Sorted array is:", sorted_arr)