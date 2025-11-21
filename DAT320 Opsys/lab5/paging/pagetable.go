package paging

// NoEntry is produced when no entry matching a request exists
const NoEntry = -1

// PageTable is a per-process data structure which holds translations from virtual page numbers to physical frame numbers
type PageTable struct {
	frameIndices []int // maps virtual page number (index) to physical frame number (content)
}

// Append adds pages to a page table
func (pt *PageTable) Append(pages []int) {
	pt.frameIndices = append(pt.frameIndices, pages...)
}

// Free removes the n last pages from the page table and returns the removed entries
func (pt *PageTable) Free(n int) ([]int, error) {
	emptyslice := []int{}
	if n > len(pt.frameIndices) {
		return emptyslice, errNothingToAllocate
	}
	if n == 0 {
		return emptyslice, nil
	}
	freed := make([]int, n)
	copy(freed, pt.frameIndices[len(pt.frameIndices)-n:])
	pt.frameIndices = pt.frameIndices[:len(pt.frameIndices)-n]
	return freed, nil
}

// Lookup returns the mapping of a virtual page number to a physical frame number, or an error if it does not exist.
func (pt *PageTable) Lookup(virtualPageNum int) (frameIndex int, err error) {
	if virtualPageNum < 0 || virtualPageNum >= len(pt.frameIndices) {
		return NoEntry, errIndexOutOfBounds
	}
	return pt.frameIndices[virtualPageNum], nil
}

// Len returns the length of the page table
func (pt *PageTable) Len() int {
	return len(pt.frameIndices)
}
