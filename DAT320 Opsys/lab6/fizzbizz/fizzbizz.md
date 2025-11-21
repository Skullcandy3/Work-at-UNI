# Task: FizzBizz

This assignment aims to test your understanding of the `sync` package, particularly **condition variables** (`sync.Cond`).

## Problem Overview

Given a number `max`, you need to implement a **concurrent** version of the classic FizzBuzz algorithm where **four goroutines run simultaneously** and must coordinate to process numbers from 1 to `max` **in order**.

## The Challenge

The main challenge is **synchronization**: all four goroutines will be running at the same time, but they must take turns to ensure numbers are processed in the correct sequential order (1, 2, 3, ..., max).

### Goroutine Responsibilities

Each goroutine is responsible for processing specific numbers according to these rules:

- **`fizz()`** appends `"Fizz"` when the current number is divisible by 3 but **not** by 5
- **`bizz()`** appends `"Bizz"` when the current number is divisible by 5 but **not** by 3
- **`number()`** appends the number (as a string) when it is **not** divisible by 3 or 5
- **`fizzBizz()`** appends `"FizzBizz"` when the current number is divisible by **both** 3 and 5

### How It Works

The `SyncBlock` structure contains:

- `current`: the current number being processed (starts at 1)
- `max`: the maximum number to process
- `result`: the accumulated output string
- `cond`: a condition variable for coordinating the goroutines
- `wg`: a WaitGroup to wait for all goroutines to complete

**Each goroutine** must:

1. Loop continuously while `current <= max`
2. Check if the current number matches its condition
3. If **yes**: append to the result, increment `current`, and signal other goroutines
4. If **no**: wait for another goroutine to process the current number

### Synchronization Diagram

```text
Time →
Goroutines:
  fizz()     │ wait │ wait │ Fizz! │ wait │ wait │ Fizz! │ ...
  bizz()     │ wait │ wait │ wait  │ wait │ Bizz!│ wait  │ ...
  number()   │  1!  │  2!  │ wait  │  4!  │ wait │ wait  │ ...
  fizzBizz() │ wait │ wait │ wait  │ wait │ wait │ wait  │ ...
             └──────┴──────┴───────┴──────┴──────┴───────┴─────
current:       1      2      3       4      5      6      ...
```

Each goroutine wakes up when signaled, checks if it's their turn, and either processes the number or goes back to waiting.

## Testing

You can check your implementation by running the test case:

```console
% go test -v -run TestFizzBizz
```

You should also run the tests with the race detector to catch potential data races:

```console
% go test -race -v -run TestFizzBizz
```

The race detector will help you identify if you're properly synchronizing access to shared variables.

## Examples

With the inputs `max = 5` and `max = 15`, the output should be:

```console
% go test -v -run TestFizzBizzWithUserInput -max 5
12Fizz4Bizz

% go test -v -run TestFizzBizzWithUserInput -max 15
12Fizz4BizzFizz78FizzBizz11Fizz1314FizzBizz
```
