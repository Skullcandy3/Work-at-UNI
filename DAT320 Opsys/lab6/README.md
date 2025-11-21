# Lab 6: Concurrency and Parallelism

| Lab 6: | Concurrency and Parallelism |
| ---------------------    | --------------------- |
| Subject:                 | DAT320 Operating Systems and Systems Programming |
| Deadline:                | **November 7, 2025 23:59** |
| Grading:                 | Pass/fail |
| Submission:              | Group |

## Table of Contents

1. [Introduction](#introduction)
2. [Recommended Reading](#recommended-reading)
3. [Condition Variables](#condition-variables)
4. [Tasks](#tasks)

## Introduction

This lab explores **concurrency** and **parallelism** in Go, covering synchronization techniques, performance optimization, and debugging concurrent programs.

### What You'll Learn

This assignment is divided into three main areas:

1. **Parallel Execution**: Implement parallel algorithms using goroutines to achieve performance speedups on multi-core systems
2. **Synchronization Techniques**: Use different approaches to coordinate concurrent access to shared data structures:
   - Traditional locking with mutexes
   - Communicating Sequential Processes (CSP) with channels
   - Condition variables for thread coordination
3. **Data Race Detection**: Learn to identify and fix data races using Go's built-in race detector
4. **Performance Profiling**: Analyze CPU and memory usage to understand and optimize program performance

### Key Concepts

**Concurrency vs Parallelism:**

- **Concurrency**: Multiple tasks making progress (may run on one core, interleaved)
- **Parallelism**: Multiple tasks running simultaneously (requires multiple cores)

**Synchronization Patterns:**

- **Mutual Exclusion (Locks)**: Protecting shared state from concurrent access
- **Condition Variables**: Coordinating goroutines that must wait for specific conditions

**Data Races:**

A data race occurs when two or more goroutines access the same variable concurrently and at least one access is a write. Data races cause unpredictable behavior and bugs that are difficult to reproduce and debug.

### Recommended Reading

Before starting the lab, familiarize yourself with these resources:

**Essential:**

- [`sync` package documentation](https://pkg.go.dev/sync) - Standard library synchronization primitives
- [Effective Go - Concurrency](http://golang.org/doc/effective_go.html#concurrency) - Go's concurrency philosophy

**Books:**

- [The Go Programming Language](http://www.gopl.io): Chapters 8 (Goroutines and Channels) and 9 (Concurrency with Shared Variables)

**Videos:**

- [Collection of Videos about Go](https://go.dev/wiki/GoTalks)
- [Concurrency is not Parallelism](https://youtu.be/f6kdp27TYZs) - Conceptual foundations

**Tutorials:**

- [Golang Tutorial Series - Concurrency](https://golangbot.com/learn-golang-series/#concurrency) - Practical examples

### Condition Variables

**Condition variables** enable thread-safe code execution that waits for specific conditions to be met before proceeding. They are essential for **coordinating goroutines** that need to wait for certain conditions before they can proceed with their work.

**Key Rules for Condition Variables:**

1. **Always hold the lock** when calling `Wait()` and `Signal()`/`Broadcast()`
2. **Always recheck the condition** after returning from a `Wait()` call (use a loop, not an if statement)

**Why these rules?**

- The lock ensures atomic checking and modification of shared state
- Rechecking prevents spurious wakeups and race conditions

**Example pattern:**

```go
mu.Lock()
for !condition {
    cond.Wait()  // Releases lock, waits, reacquires lock
}
// Critical section - condition is true
mu.Unlock()
```

Read more in the [`sync.Cond` documentation](https://pkg.go.dev/sync#Cond).

## Tasks

Complete the following tasks. Each focuses on different aspects of concurrent programming:

- **[Word Count](wordcount/wordcount.md)** - Parallel execution and performance benchmarking
- **[Concurrent Stack](stack/stack.md)** - Synchronization with locks and CSP, profiling analysis  
- **[FizzBizz](fizzbizz/fizzbizz.md)** - Condition variables and goroutine coordination
