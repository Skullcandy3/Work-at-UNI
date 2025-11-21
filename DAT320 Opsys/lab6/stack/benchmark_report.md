# Benchmark Report

## CPU and Memory Benchmarks for all Three Stacks

```console
$ go test -v -run none -bench Benchmark -memprofilerate=1 -benchmem
```

1. How much faster than the slowest is the fastest stack?
    - [ ] a) 2x-3x
    - [ ] b) 3x-4x
    - [x] c) 5x-20x
    - [ ] d) 20x-30x

2. Which stack requires the most allocated memory?
    - [x] a) CspStack
    - [ ] b) SliceStack
    - [ ] c) SafeStack
    - [ ] d) UnsafeStack

3. Which stack requires the least amount of allocated memory?
    - [ ] a) CspStack
    - [x] b) SliceStack
    - [ ] c) SafeStack
    - [ ] d) UnsafeStack

## Memory Profile of BenchmarkStacks/SafeStack

```console
$ go test -v -run none -bench BenchmarkStacks/SafeStack -memprofile=safe-stack.prof
$ go tool pprof safe-stack.prof
```

4. Which function accounts for all memory allocations in the `SafeStack` implementation?
    - [ ] a) `Size`
    - [ ] b) `NewSafeStack`
    - [x] c) `Push`
    - [ ] d) `Pop`

5. Which line in `SafeStack` does the actual memory allocation?
    - [ ] a) `type SafeStack struct {`
    - [x] b) `ss.top = &Element{value, ss.top}`
    - [ ] c) `value, ss.top = ss.top.value, ss.top.next`
    - [ ] d) `top  *Element`

## CPU Profile of BenchmarkStacks/CspStack

```console
$ go test -v -run none -bench BenchmarkStacks/CspStack -cpuprofile=csp-stack.prof
$ go tool pprof csp-stack.prof
```
