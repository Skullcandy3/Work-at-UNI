package stride

import (
	"dat320/lab4/scheduler/cpu"
	"dat320/lab4/scheduler/job"
	"fmt"
	"time"
)

type stride struct {
	queue   job.Jobs
	cpu     *cpu.CPU
	quantum time.Duration
	lastRun time.Duration
}

func New(cpus []*cpu.CPU, quantum time.Duration) *stride {
	return &stride{
		cpu:     cpus[0],
		queue:   make(job.Jobs, 0),
		quantum: quantum,
		lastRun: 0,
	}
}

func (s *stride) Add(job *job.Job) {
	s.queue = append(s.queue, job)
}

// Schedule is called by the system at every system tick
// to check if the scheduler should reassign the CPU to another job
func (s *stride) Schedule(systemTime time.Duration) {
	if len(s.queue) == 0 {
		fmt.Println("Queue is empty")
		return // nothing to do
	}

	if !s.cpu.IsRunning() {
		// CPU is idle — assign next job
		fmt.Println("CPU is idle, reassigning...")
		s.lastRun = systemTime
		s.reassign()
		return
	}

	// CPU is running — check quantum
	if systemTime-s.lastRun >= s.quantum {
		if s.cpu.CurrentJob() != nil && s.cpu.CurrentJob().Remaining() > 0 {
			s.queue = append(s.queue, s.cpu.CurrentJob())
		}
		s.cpu.Assign(nil)
		s.lastRun = systemTime
		s.reassign()
	}

	// Debugging: print current job and time
	if s.cpu.IsRunning() {
		fmt.Printf("Time: %v, Current Job: %v\n", systemTime, s.cpu.CurrentJob())
	} else {
		fmt.Printf("Time: %v, CPU is idle\n", systemTime)
	}
}

// reassign assigns a job to the cpu
func (s *stride) reassign() {
	index := MinPass(s.queue)
	nextJob := s.queue[index]

	// Remove job at index
	s.queue = append(s.queue[:index], s.queue[index+1:]...)

	// Update pass before assigning
	nextJob.Pass += nextJob.Stride

	s.cpu.Assign(nextJob)
}

// MinPass returns the index of the job with the lowest Pass value.
// If two jobs have the same Pass, the job with the smaller Stride wins.
func MinPass(theJobs job.Jobs) int {
	lowest := 0
	for i := 1; i < len(theJobs); i++ {
		if theJobs[i].Pass < theJobs[lowest].Pass ||
			(theJobs[i].Pass == theJobs[lowest].Pass && theJobs[i].Stride < theJobs[lowest].Stride) {
			lowest = i
		}
	}
	return lowest
}
