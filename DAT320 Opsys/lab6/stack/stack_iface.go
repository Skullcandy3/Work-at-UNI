package stack

// Stack interface has methods for interacting with the stack.
type Stack interface {
	// Size returns the size of the stack.
	Size() int
	// Push pushes value onto the stack.
	Push(value any)
	// Pop pops the value at the top of the stack and returns it.
	Pop() any
}

// Element is the element to be held in the stack.
type Element struct {
	value any
	next  *Element
}
