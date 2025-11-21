package stack

import (
	"sync"
)

// DefaultCap is the default stack capacity.
const DefaultCap = 10

// SliceStack is a struct with methods needed to implement the Stack interface.
type SliceStack struct {
	slice []any
	top   int
	mu    sync.Mutex
}

// NewSliceStack returns an empty SliceStack.
func NewSliceStack() *SliceStack {
	return &SliceStack{
		slice: make([]any, DefaultCap),
		top:   -1,
	}
}

// Size returns the size of the stack.
func (ss *SliceStack) Size() int {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	return ss.top + 1
}

// Push pushes value onto the stack.
func (ss *SliceStack) Push(value any) {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	ss.top++
	if ss.top == len(ss.slice) {
		// Reallocate
		newSlice := make([]any, len(ss.slice)*2)
		copy(newSlice, ss.slice)
		ss.slice = newSlice
	}
	ss.slice[ss.top] = value
}

// Pop pops the value at the top of the stack and returns it.
func (ss *SliceStack) Pop() (value any) {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	if ss.top > -1 {
		defer func() { ss.top-- }()
		return ss.slice[ss.top]
	}
	return nil
}
