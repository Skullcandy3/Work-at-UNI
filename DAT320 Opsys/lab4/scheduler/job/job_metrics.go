package job

import (
	"dat320/lab4/scheduler/system/systime"
	"time"
)

func (j *Job) Arrived(s systime.SystemTime) {
	j.SystemTime = s
	j.arrival = j.Now()
}

func (j Job) Arrival() time.Duration {
	return j.arrival
}

func (j *Job) Started(cpuID int) {
	if j.start == NotStartedYet { // only set start once
		j.start = j.Now() // record first start time
	}
	// DO NOT overwrite j.id
}

func (j *Job) Finished() {
	j.finished = j.Now()
}

func (j Job) TurnaroundTime() time.Duration {
	// Time from arrival until finished
	return j.finished - j.arrival
}

func (j Job) ResponseTime() time.Duration {
	// Time from arrival until first start
	return j.start - j.arrival
}
