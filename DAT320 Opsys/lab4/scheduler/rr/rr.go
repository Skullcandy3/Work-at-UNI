package rr

import (
	"dat320/lab4/scheduler/cpu"
	"dat320/lab4/scheduler/job"
	"fmt"
	"time"
)

type roundRobin struct {
	queue   job.Jobs
	cpu     *cpu.CPU
	quantum time.Duration
	lastRun time.Duration
}

func New(cpus []*cpu.CPU, quantum time.Duration) *roundRobin {
	if len(cpus) == 0 {
		return nil
	}
	return &roundRobin{
		cpu:     cpus[0],
		queue:   job.Jobs{},
		quantum: quantum,
		lastRun: 0,
	}
}

func (rr *roundRobin) Add(j *job.Job) {
	if j != nil {
		rr.queue = append(rr.queue, j)
	}
}

// Select the first job in the queue (FIFO order).
// Remove it from the queue to simulate dispatching.

// Assign the job to the CPU for execution.
// In a complete RR implementation, we would also:
// - Start a timer for the quantum duration.
// - After the quantum expires, check if the job is finished.
// - If not finished, requeue the job at the end of the queue.
// - If finished, discard it and proceed to the next job.

// This function currently lacks quantum enforcement and job requeuing.
// These need to be implemented to make the scheduler truly round-robin.

func (rr *roundRobin) Schedule(systemTime time.Duration) {
	if len(rr.queue) == 0 && !rr.cpu.IsRunning() {
		// no jobs in queue, CPU is idle
		return
	}
	// cpu.IsRunning() returns true if the CPU is currently running a job
	// and the job has not yet finished
	if rr.cpu.IsRunning() {
		// CPU is busy, check if quantum has expired
		if systemTime-rr.lastRun < rr.quantum {
			// Quantum not expired, continue running current job
			return
		}
		// Quantum expired, requeue current job if not finished
		if rr.cpu.CurrentJob() != nil && rr.cpu.CurrentJob().Remaining() > 0 {
			rr.queue = append(rr.queue, rr.cpu.CurrentJob())
			rr.cpu.Assign(nil) // Preempt current job
			rr.lastRun = systemTime
		}
	}

	// If CPU is idle, assign next job
	if !rr.cpu.IsRunning() {
		rr.lastRun = systemTime
		rr.reassign()
		return
	}

	// Debugging: print current job and time
	if rr.cpu.IsRunning() {
		fmt.Printf("Time: %v, Current Job: %v\n", systemTime, rr.cpu.CurrentJob())
	} else {
		fmt.Printf("Time: %v, CPU is idle\n", systemTime)
	}

}

// reassign assigns the next job in the queue to the CPU
func (rr *roundRobin) reassign() {
	nextJob := rr.queue[0]
	rr.queue = rr.queue[1:]
	rr.cpu.Assign(nextJob)
}

// ✔ Track job start time or elapsed time per job.
// ✔ Preempt job when quantum expires.
// ✔ Requeue unfinished jobs.
// ✔ Assign next job from queue.
// ✔ Ensure fairness and alternation between jobs.
