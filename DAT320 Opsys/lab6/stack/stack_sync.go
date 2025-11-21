package stack

import (
	"sync"
)

// SafeStack holds the top element of the stack and its size.
type SafeStack struct {
	top  *Element
	size int
	mu   sync.Mutex
}

// Size returns the size of the stack.
func (ss *SafeStack) Size() int {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	return ss.size
}

// Push pushes value onto the stack.
func (ss *SafeStack) Push(value any) {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	ss.top = &Element{value, ss.top}
	ss.size++
}

// Pop pops the value at the top of the stack and returns it.
func (ss *SafeStack) Pop() (value any) {
	ss.mu.Lock()
	defer ss.mu.Unlock()
	if ss.size > 0 {
		value, ss.top = ss.top.value, ss.top.next
		ss.size--
		return
	}
	return nil
}
