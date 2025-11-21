/*
Task 5: Errors needed for multiwriter

You may find this blog post useful:
http://blog.golang.org/error-handling-and-go

Similar to a the Stringer interface, the error interface also defines a
method that returns a string.

	type error interface {
	    Error() string
	}

Thus also the error type can describe itself as a string. The fmt package (and
many others) use this Error() method to print errors.

Implement the Error() method for the Errors type defined above.

The following conditions should be covered:

1. When there are no errors in the slice, it should return:

"(0 errors)"

2. When there is one error in the slice, it should return:

The error string return by the corresponding Error() method.

3. When there are two errors in the slice, it should return:

The first error + " (and 1 other error)"

4. When there are X>1 errors in the slice, it should return:

The first error + " (and X other errors)"
*/
package errors

import (
	"fmt"
)

func (m Errors) Error() string {
	// collect only non-nil errors
	var nonNil []error
	for _, err := range m {
		if err != nil {
			nonNil = append(nonNil, err)
		}
	}

	n := len(nonNil)
	switch n {
	case 0:
		return "(0 errors)"
	case 1:
		return nonNil[0].Error()
	case 2:
		return nonNil[0].Error() + " (and 1 other error)"
	default:
		return fmt.Sprintf("%s (and %d other errors)", nonNil[0].Error(), n-1)
	}
}
