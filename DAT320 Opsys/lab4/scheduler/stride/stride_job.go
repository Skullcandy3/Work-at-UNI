package stride

import (
	"dat320/lab4/scheduler/job"
	"time"
)

// NewJob creates a job for stride scheduling.
func NewJob(size, tickets int, estimated time.Duration) *job.Job {
	const numerator = 10_000

	// Create a properly initialized job using job.New
	j := job.New(size, estimated)

	// Set stride scheduling fields
	j.Tickets = tickets
	j.Stride = numerator / tickets
	j.Pass = 0 // Start with pass = 0

	return j
}
