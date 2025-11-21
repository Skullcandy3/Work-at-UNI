package stack

type stackOperation int

const (
	size stackOperation = iota
	push
	pop
)

type stackCommand struct {
	op       stackOperation
	value    any
	response chan any
}

// CspStack is a struct with methods needed to implement the Stack interface.
type CspStack struct {
	size     int
	commands chan stackCommand
}

// NewCspStack returns an empty CspStack.
func NewCspStack() *CspStack {
	cs := &CspStack{
		commands: make(chan stackCommand),
	}
	go cs.run()
	return cs
}

// Size returns the size of the stack.
func (cs *CspStack) Size() int {
	response := make(chan any)
	cs.commands <- stackCommand{op: size, response: response}
	res := <-response
	return res.(int)
}

// Push pushes value onto the stack.
func (cs *CspStack) Push(value any) {
	response := make(chan any)
	cs.commands <- stackCommand{op: push, response: response, value: value}
	<-response
}

// Pop pops the value at the top of the stack and returns it.
func (cs *CspStack) Pop() (value any) {
	response := make(chan any)
	cs.commands <- stackCommand{op: pop, response: response}
	return <-response
}

func (cs *CspStack) run() {
	var top *Element
	for cmd := range cs.commands {
		switch cmd.op {
		case size:
			cmd.response <- cs.size
		case push:
			top = &Element{value: cmd.value, next: top}
			cs.size++
			cmd.response <- nil
		case pop:
			if top != nil {
				cmd.response <- top.value
				top = top.next
				cs.size--
			} else {
				cmd.response <- nil
			}
		}
	}
}
