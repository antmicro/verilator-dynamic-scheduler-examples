# Verilator with a dynamic scheduler

Copyright (c) 2021-2022 [Antmicro](https://www.antmicro.com)

This repository contains a number of examples that showcase our attempt at implementing a dynamic scheduler for Verilator, which can be found [here](https://github.com/antmicro/verilator-1/tree/dynamic-scheduler), as well as limited support for `randomize` constraints (available [here](https://github.com/antmicro/verilator-1/tree/randomize-constraints)).

This version of Verilator requires GCC 10 or newer, or Clang (tested with Clang 13).

After cloning, please run:
``` sh
git submodule update --init
```

You can run these examples using `make`:

``` sh
make EXAMPLE
```

where `EXAMPLE` is the name of one of the directories in `examples` (listed below).

## Available examples

* `uart` – the biggest and most interesting one, it's a testbench for a UART transmitter and receiver,
* `clock` – generation of a clock in an `initial` block using delays,
* `events` – event triggers, event controls, events in sensitivity lists,
* `fork` – a showcase of the `fork` functionality, along with all possible `join` types,
* `pong` – two `initial` blocks sending events to each other over multiple timeslots,
* `randomize` – demonstrates support for the `randomize` class function with constraints,
* `wait` – shows the `wait` statement in action.

## New functionality

### Delays

Delay controls enable you to postpone the execution of some part of a process till a later simulation time. A simple example that generates a clock:

``` systemverilog
initial
    forever begin
        #1 clk = 1'b0;
        #1 clk = 1'b1;
    end
```

### Events

Events give you the ability to synchronize the execution of multiple processes. Vanilla Verilator already supports them in sensitivity lists, but our version of Verilator lets you wait on events within a process block.

``` systemverilog
initial
    forever begin
        @ping;
        #1 ->pong;
    end
initial
    forever begin
        #1 ->ping;
        @pong;
    end
```

You can wait on multiple events at once:

``` systemverilog
@(a, b, c)
$display("got a, b, or c");
```

It's even possible to wait on signal edges, as well as mix events with signal edges:

``` systemverilog
@(e, posedge clk)
$display("got e or clk's posedge");
```

### Forks

Forks start parallel processes from another process. All possible forms of `join` are available (`join` waits for all forked processes to end, `join_any` waits for one to end, `join_none` does not wait).

``` systemverilog
fork
    $write("forked 1\n");
    $write("forked 2\n");
    $write("forked 3\n");
join
$write("waited for all forked processes");
```

### Wait statement

`wait` statements allow you to block the execution of a process until its condition is fulfilled. They accept even complex conditions:

``` systemverilog
wait((A < B && B > C) || A == C)
$display("B is greater than both A and C, or A equals C");
```

### Randomize class function with constraints

`randomize` is a built-in function available for all Verilog class instances. It populates class fields marked as `rand` with random values, subject to constraints specified either within the class, or next to `randomize`'s call site, using the `with` keyword.

``` systemverilog
class Cls;
   constraint A { x inside {3, 5, 8, 13}; }

   rand int x;
   rand int y;
endclass

module t;
   Cls obj;
   initial begin
      int rand_result;
      obj = new;
      rand_result = obj.randomize() with { y > 16; y < 42; };
   end
endmodule
```
