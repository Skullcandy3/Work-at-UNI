package paging

import (
	"testing"

	"github.com/google/go-cmp/cmp"
)

// normalizeSlice returns an empty slice if t is nil.
// This way we allow students to return both nil and empty slices.
func normalizeSlice[T any](t []T) []T {
	if t == nil {
		return []T{}
	}
	return t
}

var FreeListFindTests = []struct {
	size int
	in   int
	want []int
	err  error
}{
	{
		size: 10,
		in:   10,
		want: []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
		err:  nil,
	},
	{
		size: 10,
		in:   0,
		want: []int{},
		err:  errFreeOutOfBounds,
	},
	{
		size: 10,
		in:   2,
		want: []int{0, 1},
		err:  nil,
	},
	{
		size: 10,
		in:   5,
		want: []int{0, 1, 2, 3, 4},
		err:  nil,
	},
	{
		size: 1,
		in:   2,
		want: []int{},
		err:  errOutOfMemory,
	},
}

func TestFindFreeFrames(t *testing.T) {
	for n, test := range FreeListFindTests {
		fl := newFreeList(test.size)

		indices, err := fl.findFreeFrames(test.in)
		if (err != nil && test.err == nil) || (err == nil && test.err != nil) {
			t.Errorf("FindFreeFrames(case: %d): Expected error %v, got %v", n, test.err, err)
		}
		if cmp := cmp.Diff(test.want, normalizeSlice(indices)); cmp != "" {
			t.Errorf("FindFreeFrames(case: %d): Unexpected free frames; (-want +got):\n%s", n, cmp)
		}

		for i, j := range indices {
			for k, l := range indices {
				if i != k && j == l {
					t.Errorf("FindFreeFrames(case: %d): Index %d is not unique", n, j)
				}
			}
		}

		for _, i := range indices {
			if fl.freeList[i] != true {
				t.Errorf("FindFreeFrames(case: %d): Index %d is marked as used", n, i)
			}
		}
	}
}
