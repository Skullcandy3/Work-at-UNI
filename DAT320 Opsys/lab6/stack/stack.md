# High-level Synchronization & Data Race Detection

This lab focuses on **high-level synchronization techniques** and **data race detection** in Go. You will implement thread-safe stack data structures using different synchronization approaches, then profile and benchmark their performance.

## Background

### Data Races

A **data race** occurs when:

- Two or more goroutines access the same variable concurrently, AND
- At least one of these accesses is a write

Data races are bugs that can cause unpredictable behavior, crashes, and corrupted data. Go provides a built-in **race detector** to help identify these issues.

### The Stack Interface

We will work with a stack data structure (LIFO - Last In, First Out) that will be accessed concurrently from multiple goroutines. The stack stores values of type `any`, meaning it can hold any value type.

**Stack Interface** (defined in `stack_iface.go`):

```go
type Stack interface {
    Size() int                  // Returns the current number of items on the stack
    Push(value any)             // Pushes an item onto the stack
    Pop() any                   // Pops an item off the stack (nil if empty)
}
```

### Testing Strategy

The file `stack_test.go` contains tests for verifying stack implementations. There are **two types of tests** for each implementation:

1. **Operations test**: Verifies that stack operations work correctly
2. **Concurrent access test**: Tests thread-safety using the race detector

You can run specific tests using the `-run` flag with a regular expression:

```console
go test -v -run TestStackOps/UnsafeStack
```

### The Race Detector

Go's built-in race detector instruments your code to detect data races at runtime. Read the [Data Race Detector documentation](http://golang.org/doc/articles/race_detector.html) for details.

Enable the race detector with the `-race` flag:

```console
go test -race -run TestConcurrentStackAccess/SafeStack
```

## Task 1: Implement Thread-Safe Stack with Locks

The file `stack_sync.go` is a copy of `stack.go`, but the type is renamed to `SafeStack`.

**Your task**: Modify `stack_sync.go` so that access to the `SafeStack` type is **synchronized** using traditional locking (mutexes), making it safe for concurrent access from multiple goroutines.

### Implementation Hints

- Use `sync.Mutex` or `sync.RWMutex` to protect shared state
- Lock before accessing or modifying the stack's internal state
- Unlock after the operation completes

### Testing

Verify your implementation passes the operations test:

```console
go test -v -run TestStackOps/SafeStack
```

Then check for data races with the race detector (should produce **no warnings**):

```console
go test -race -run TestConcurrentStackAccess/SafeStack
```

## Task 2: Implement Thread-Safe Stack with CSP

Go provides a high-level API for concurrent programming based on **Communicating Sequential Processes (CSP)**. This approach promotes synchronization through **sending and receiving data via channels**, rather than using locks.

The file `stack_csp.go` contains a `CspStack` type with empty method implementations.

**Your task**: Modify `stack_csp.go` to implement thread-safe stack operations using Go's **channels and goroutines**.

### CSP Architecture

The CSP approach uses a different design pattern:

1. **Command channel**: Define a channel for sending stack commands
2. **Background goroutine**: The `run()` method processes commands in a separate goroutine
3. **Request-response**: Stack methods send commands and wait for responses

**Command structure**:

- `op`: The operation type (push, pop, size)
- `value`: The value to push (for push operations)
- **Response channel**: A channel to send back the result

The `run()` method should:

- Loop continuously, receiving commands from the channel
- Process each command in order (maintaining FIFO for commands)
- Send responses back through the appropriate response channel
- Use the underlying `UnsafeStack` to store data (since only one goroutine accesses it)

### Implementation Hints

- Add a command channel field to `CspStack`
- Add response channel field(s) to `stackCommand`
- In `NewCspStack()`, create the channel and start the `run()` goroutine
- Each Stack method should send a command and wait for a response
- The `run()` method handles all commands sequentially, eliminating race conditions

**Note**: There is overhead when using channels for synchronization compared to locks. The goal here is to learn CSP-style synchronization, not necessarily to create the fastest implementation.

### Resources

- [Effective Go - Concurrency](http://golang.org/doc/effective_go.html#concurrency)
- [Go by Example - Channels](https://gobyexample.com/channels)

### Testing

Verify operations work correctly:

```console
go test -v -run TestStackOps/CspStack
```

Check for data races (should produce **no warnings**):

```console
go test -v -race -run TestConcurrentStackAccess/CspStack
```

## Part 2: Performance Analysis - CPU and Memory Profiling

Now that you have implemented thread-safe stacks using two different synchronization approaches (locks and CSP), it's time to analyze and compare their performance characteristics.

### Background on Profiling

**Profiling** is a dynamic analysis technique used to measure:

- **CPU utilization**: Where your program spends its execution time
- **Memory usage**: How much memory is allocated and where

Profiling is essential for **optimizing performance** and is a critical skill in systems programming.

### Go's Profiling Tools

Go provides built-in profiling support:

- **`runtime/pprof`** package: For adding profiling to programs
- **`testing`** package: Built-in profiling support for benchmarks
- **`go tool pprof`**: Tool for analyzing profile data

### Benchmarking Setup

The file `stack_test.go` contains `BenchmarkStacks` which benchmarks all stack implementations by:

1. Pushing 10,000 items onto the stack
2. Popping all 10,000 items
3. Measuring the time and memory used

The stacks are **not** accessed concurrently during benchmarking to ensure deterministic results.

Run benchmarks with:

```console
go test -run none -bench BenchmarkStacks
```

The `-run none` flag skips regular tests (no test name matches "none"), running only benchmarks.

### Resources

Before starting the tasks, read:

- [Profiling Go Programs](https://blog.golang.org/pprof) - Comprehensive profiling introduction
- [testing package documentation](http://golang.org/pkg/testing/) - Benchmarking details
- [testing flags](http://golang.org/cmd/go/#Description_of_testing_flags) - Available flags for profiling
- [The Go Memory Model](http://golang.org/ref/mem) - Understanding memory guarantees
- [Introducing the Go Race Detector](http://blog.golang.org/race-detector) - Race detector deep dive

### Task: Multiple Choice Questions About CPU and Memory Profiling and Data Races

Answer these multiple choice questions about [CPU and Memory Profiling and Data Races](profile_race_questions.md).

## Task: Benchmarking and Profiling Go Programs

In this task, you should fill in answers in the provided template: [`benchmark_report.md`](benchmark_report.md).
You can add figures in a directory `fig`, and add markdown links from the benchmark report file, so that the figures display nicely on GitHub's web page.

1. The file `stack_slice.go` contains a stack implementation, `SliceStack`, backed by a slice (dynamic array).
   You will need to adjust this implementation to be synchronized in the exact same way you did for the `SafeStack` type.
   This has to be done to make the benchmark between the three implementations fair and comparable.

2. Run the three stack benchmarks using the following command.

   ```console
   go test -v -run none -bench BenchmarkStacks -memprofilerate=1 -benchmem
   ```

   That is we don't run any tests, because we are only interested in the benchmarks, matched by the `-bench BenchmarkStacks` flag.
   The command also enables memory allocation statistics by supplying the `-benchmem` flag, and the `-memprofilerate` controls the fraction of memory allocations that are recorded and reported in the memory profile.
   By passing 1 here means all allocations are reported.

   Attach the benchmark output in your [`benchmark_report.md`](benchmark_report.md) and answer the questions.

3. Run the `CspStack` benchmark separately and write a CPU profile to file:

   ```console
   go test -v -run none -bench BenchmarkStacks/CspStack -cpuprofile=csp-stack.prof
   ```

   Load the CPU profile data with the `pprof` tool.

   ```console
   go tool pprof csp-stack.prof
   ```

   Attach the benchmark and profile output in your [`benchmark_report.md`](benchmark_report.md), and answer the questions related the top ten functions from your CPU profile.

4. Run the `SafeStack` benchmarks separately and write a memory profile to file:

   ```console
   go test -v -run none -bench BenchmarkStacks/SafeStack -memprofile=safe-stack.prof
   ```

   Using the `pprof` tool:

   ```console
   go tool pprof safe-stack.prof
   ```

   Identify the function allocating memory in the `SafeStack` implementation, and list the relevant function to identify the line where the allocations occur.
   Attach the profile output in your [`benchmark_report.md`](benchmark_report.md), and answer the questions related to memory allocations.

5. Install [Graphviz](http://www.graphviz.org/).
   Explore the visualization possibilities offered by `go tool pprof` when analyzing profiling data.
   Use the `pdf` command to produce a call graph:

   ```console
   $ go tool pprof csp-stack.prof
   ...
   (pprof) pdf
   Generating report in profile001.pdf
   (pprof) quit
   ```

   Add the `profile001.pdf` to the `fig/` folder in your group's repository.
   Examine the call graph visualization and answer the questions in the [`benchmark_report.md`](benchmark_report.md).
