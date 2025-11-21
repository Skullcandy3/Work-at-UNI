package system

import (
	"time"

	"dat320/lab4/scheduler/job"
)

type Scheduler interface {
	Add(*job.Job)
	Schedule(time.Duration)
}
