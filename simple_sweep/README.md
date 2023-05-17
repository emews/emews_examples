Simple Sweep EMEWS Example
-----------------------

This directory contains a simple UPF (unrollowed parameter file) sweep example.
Each line in the file contains a single integer. That integer is passed to 
a simple Python/R code snippet and which is executed by Swift/T. The result
is added to a result array, and the sum of the array is printed. 

The Python/R code multiplies the upf line integer by 2:

```
x = %s * 2
```

where `%s` is replaced by the upf integer before executing the code.

To run the example:

```bash
$ cd swift
$ ./run_simple_sweep.sh <exp_id> cfgs/simple_sweep.cfg
```

where exp_id is an experiment id such as "test_1". An experiment directory
will be created from the experiment id (e.g., `experiments/test_1`) and
the configuration file, the upf, and log info will be written to there.

The number of processes to use and whether to run the code snippet
with Python or R is set in `cfgs/simple_sweep.cfg`