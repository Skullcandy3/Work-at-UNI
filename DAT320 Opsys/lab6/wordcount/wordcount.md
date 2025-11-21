# Task: Parallel Word Count

This assignment demonstrates how **parallel execution** can improve performance on CPU-intensive tasks. You will implement a parallel word counting algorithm that distributes work across multiple goroutines.

## Problem Overview

You are given a large text file (`mobydick.txt`, the full text of Moby Dick) containing 175,131 words. Your task is to count these words using **multiple goroutines running in parallel** to achieve better performance than a sequential implementation.

## The Challenge

While parallel execution in Go is relatively straightforward, the challenge here is to:

1. **Divide the work** into chunks that can be processed independently
2. **Coordinate goroutines** to count their portions simultaneously
3. **Aggregate results** from all goroutines to get the final count
4. **Achieve speedup** - your parallel version must be faster than the sequential version

### Understanding the Work Division

The key insight is that word counting can be parallelized by:

- Splitting the input text into **shards** (sub-slices)
- Having each goroutine count words in its shard
- Combining the counts from all shards

## Provided Functions

We have provided three helper functions in `wc.go`:

- **`loadMoby()`**: Loads the `mobydick.txt` file and returns it as a `[]byte`
- **`wordCount(input []byte)`**: Counts words in a byte slice sequentially (the baseline implementation)
- **`shardSlice(input []byte, numShards int)`**: Splits the input into `numShards` sub-slices, ensuring splits occur at word boundaries (spaces)

You can use these functions as building blocks for your parallel implementation.

## Implementation Tasks

### 1. Implement Parallel Word Count

Implement the `doParallelWordCount()` function with the following signature:

```go
func doParallelWordCount(input []byte, numShards int) (words int)
```

This function must:

- Split the input into `numShards` parts using `shardSlice()`
- Launch goroutines to count words in each shard
- Coordinate and aggregate the results from all goroutines
- Return the total word count

The `parallelWordCount()` wrapper function calls your implementation with `runtime.NumCPU()` goroutines (typically one per CPU core).

#### Testing

Run the test to verify correctness (should count 175,131 words):

```console
go test -v -run TestParallelWordCount
```

Test with varying numbers of shards:

```console
go test -v -run TestParallelWordCountManyShards
```

### 2. Benchmark Performance

After implementing the parallel version, benchmark it against the sequential version:

```console
go test -v -run XX -bench BenchmarkWordCount
```

The `-run XX` flag skips regular tests (no test matches "XX"), running only benchmarks.

#### Understanding Benchmark Output

The benchmark will show something like:

```text
BenchmarkWordCountSequential-8    100    12345678 ns/op
BenchmarkWordCountParallel-8      300     4123456 ns/op
```

Where:

- The number after the dash (e.g., `-8`) is the number of CPU cores
- The first number (e.g., `100`, `300`) is how many iterations ran
- The second number is nanoseconds per operation (lower is better)

**Your parallel implementation must be faster** (lower ns/op) than the sequential version. The TAs will verify this during approval.

#### Performance Tips

- Splitting into too many shards can cause overhead
- Generally, `runtime.NumCPU()` shards is a good starting point
- On multi-core machines, you should see significant speedup

## Testing Summary

```console
# Verify correctness
go test -v -run TestParallelWordCount

# Test with different shard counts
go test -v -run TestParallelWordCountManyShards

# Benchmark performance
go test -v -run XX -bench BenchmarkWordCount

# Benchmark with race detector (will be slower but verifies correctness)
go test -race -run XX -bench BenchmarkWordCount
```

Complete the code marked with `TODO(student)` in the `doParallelWordCount()` function.
