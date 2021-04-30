# Verilator with a dynamic scheduler

This repository contains a number of examples that showcase our attempt at implementing a dynamic scheduler for Verilator, which can be found [here](https://github.com/antmicro/verilator-1/tree/dynamic-scheduler), and as a submodule in this repository.

After cloning, please run:
``` sh
git submodule update --init
```

You can run these examples using `make`:

``` sh
make TESTNAME
```

where `TESTNAME` is the name of one of the directories in `examples` (listed below).

## Available examples

* `uart` – the biggest and most interesting one, it's a testbench for a UART transmitter and receiver,
* `clock` – generation of a clock in an `initial` block using delays,
* `events` – event triggers, event controls, events in sensitivity lists,
* `fork` – a showcase of the `fork` functionality, along with all possible `join` types,
* `pong` – two `initial` blocks sending events to each other over multiple timeslots,
* `wait` – shows the `wait` statement in action.

## New functionality

### Delays

Delay controls enable you to postpone the execution of some part of a process till a later simulation time. A simple example that generates a clock:

``` systemverilog
initial begin
    forever begin
        #1 clk = 1'b0;
        #1 clk = 1'b1;
    end
end
```

### Events

Events give you the ability to synchronize the execution of multiple processes. Vanilla Verilator already supports them in sensitivity lists, but our version of Verilator lets you wait on events within a process block.

``` systemverilog
initial begin
    forever begin
        @ping;
        #1 ->pong;
    end
end
initial begin
    forever begin
        #1 ->ping;
        @pong;
    end
end
```

You can wait on multiple events at once:

``` systemverilog
@(a, b, c);
$display("got a, b, or c");
```

It's even possible to wait on signal edges, as well as mix events with signal edges:

``` systemverilog
@(e, posedge clk);
$display("got e or clk's posedge");
```

### Forks

Forks start parallel processes from another process. All possible forms of `join` are available (`join` waits for all forked processes to end, `join_any` waits for one to end, `join_none` does not wait).

``` systemverilog
fork
    begin $write("forked 1\n"); end
    begin $write("forked 2\n"); end
    begin $write("forked 3\n"); end
join
$write("waited for all forked processes");
```

### Wait statement

`wait` statements allow you to block the execution of a process until its condition is fulfilled. They accept even complex conditions:

``` systemverilog
wait((A < B && B > C) || A == C);
$display("B is greater than both A and C, or A equals C");
```
