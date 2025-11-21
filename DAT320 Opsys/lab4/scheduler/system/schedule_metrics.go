package system

import (
	"time"
)

func (sch Schedule) AvgResponseTime() time.Duration {
	if len(sch) == 0 {
		return 0
	}

	var sum time.Duration
	for _, e := range sch {
		sum += e.Job.ResponseTime()
	}
	return sum / time.Duration(len(sch))
}

func (sch Schedule) AvgTurnaroundTime() time.Duration {
	if len(sch) == 0 {
		return 0
	}

	var sum time.Duration
	for _, e := range sch {
		sum += e.Job.TurnaroundTime()
	}
	return sum / time.Duration(len(sch))
}
