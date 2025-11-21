package sjf

import (
	"dat320/lab4/scheduler/cpu"
	"dat320/lab4/scheduler/job"
	"sort"
	"time"
)

type sjf struct {
	queue job.Jobs
	cpu   *cpu.CPU
}

func New(cpus []*cpu.CPU) *sjf {
	if len(cpus) == 0 {
		return nil
	}
	return &sjf{
		queue: make(job.Jobs, 0),
		cpu:   cpus[0], // single CPU
	}
}

func (s *sjf) Add(j *job.Job) {
	s.queue = append(s.queue, j)
}

// Schedule is called every tick to potentially reassign CPU
func (s *sjf) Schedule(systemTime time.Duration) {
	// if CPU is idle or current job finished, pick next
	if !s.cpu.IsRunning() {
		s.reassign(systemTime)
		return
	}
}

// reassign picks the shortest arrived job and assigns it to CPU
func (s *sjf) reassign(systemTime time.Duration) {
	arrived := make(job.Jobs, 0)
	for _, j := range s.queue {
		if j.Arrival() <= systemTime {
			arrived = append(arrived, j)
		}
	}

	if len(arrived) == 0 {
		// no job ready, keep CPU idle
		s.cpu.Assign(nil)
		return
	}

	// pick job with smallest remaining time
	sort.Slice(arrived, func(i, j int) bool {
		return arrived[i].Remaining() < arrived[j].Remaining()
	})

	nextJob := arrived[0]
	// assign CPU
	s.cpu.Assign(nextJob)

	// remove job from queue
	for i, j := range s.queue {
		if j.ID() == nextJob.ID() {
			s.queue = append(s.queue[:i], s.queue[i+1:]...)
			break
		}
	}
}
