# Manually Partition into Training, Test and Validation Set

Creates a split of the row ids of a
[mlr3::Task](https://mlr3.mlr-org.com/reference/Task.html) into a
training and a test set, and optionally a validation set.

## Usage

``` r
# S3 method for class 'TaskFcst'
partition(task, ratio = 0.67)
```

## Arguments

- task:

  ([Task](https://mlr3.mlr-org.com/reference/Task.html))  
  Task to operate on.

- ratio:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Ratio of observations to put into the training set. If a 2 element
  vector is provided, the first element is the ratio for the training
  set, the second element is the ratio for the test set. The validation
  set will contain the remaining observations.

## Examples

``` r
task = tsk("airpassengers")
split = partition(task, ratio = 0.8)
```
