package paging

func (fl *freeList) findFreeFrames(n int) ([]int, error) {
	if n <= 0 {
		return nil, errNothingToAllocate
	}

	frames := []int{}
	for i, isFree := range fl.freeList {
		if isFree {
			frames = append(frames, i)
			if len(frames) == n {
				break
			}
		}
	}

	if len(frames) < n {
		return nil, errOutOfMemory
	}

	return frames, nil
}
