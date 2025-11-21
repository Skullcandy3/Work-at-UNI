package slices

// Sort should sort the slice in-place in ascending order.
// example: sort([]int{5, 3, 8, 6, 2}) should modify the slice to []int{2, 3, 5, 6, 8}
func sort(slice []int) {

	for i := 0; i < len(slice)-1; i++ {
		for j := 0; j < len(slice)-i-1; j++ {
			if slice[j] > slice[j+1] {
				// Swap
				slice[j], slice[j+1] = slice[j+1], slice[j]
			}
		}
	}
}

// Unique should return a new sorted slice with duplicates removed.
// example: unique([]int{1, 2, 2, 3}) should return []int{1, 2, 3}
func unique(slice []int) []int {

	sort(slice)
	result := []int{}
	for i := 0; i < len(slice); i++ {
		if i == 0 || slice[i] != slice[i-1] {
			result = append(result, slice[i])
		}
	}
	return result
}

// Combine should return a new slice that combines two slices and removes duplicates.
// The result should be sorted in ascending order.
// example: combine([]int{1, 2, 3}, []int{4, 2, 5}) should return []int{1, 2, 3, 4, 5}
func combine(slice1, slice2 []int) []int {

	combined := append(slice1, slice2...)
	return unique(combined)
}
