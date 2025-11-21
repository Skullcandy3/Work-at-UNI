package fifo

import (
	"time"

	"dat320/lab4/scheduler/cpu"
	"dat320/lab4/scheduler/job"
)

type fifo struct {
	cpu   *cpu.CPU
	queue job.Jobs
}

func New(cpus []*cpu.CPU) *fifo {
	if len(cpus) != 1 {
		panic("fifo scheduler supports only a single CPU")
	}
	return &fifo{
		cpu:   cpus[0],
		queue: make(job.Jobs, 0),
	}
}

// New jobs are added by the system as they arrive
// We keep track of the jobs in our queue
func (f *fifo) Add(job *job.Job) {
	f.queue = append(f.queue, job)
}

// Schedule is called by the system at every system tick
// to check if the scheduler should reassign the CPU to another job
func (f *fifo) Schedule(systemTime time.Duration) {
	if len(f.queue) == 0 {
		// no jobs in queue, do nothing
		return
	}
	// cpu.IsRunning() returns true if the CPU is currently running a job
	// and the job has not yet finished
	if f.cpu.IsRunning() {
		// CPU is busy, do nothing
		return
	}

	// CPU is idle, find and assign next job in queue
	f.reassign()
}

// reassign assigns the next job in the queue to the CPU
func (f *fifo) reassign() {
	nextJob := f.queue[0]
	f.queue = f.queue[1:]
	f.cpu.Assign(nextJob)
}
