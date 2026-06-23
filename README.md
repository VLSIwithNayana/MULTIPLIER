# UVM Verification of 4-bit Multiplier

## Overview

This project implements a UVM-based verification environment for a 4-bit multiplier. Randomized stimulus is generated and applied to the DUT, while a scoreboard checks the correctness of the output.

## DUT

* 4-bit inputs: `a`, `b`
* 8-bit output: `y = a × b`

## Verification Components

* Sequence (Generator)
* Sequencer
* Driver
* Monitor
* Agent
* Environment
* Scoreboard
* Test

## Features

* Random stimulus generation
* Driver-Sequencer communication
* Monitor with analysis port
* Scoreboard-based checking
* Reusable UVM architecture

## Simulation Flow

```text
Sequence → Driver → DUT → Monitor → Scoreboard
```

## Language and Methodology

* SystemVerilog
* UVM

## Simulator

* QuestaSim / VCS / Xcelium

## Future Enhancements

* Functional Coverage
* SystemVerilog Assertions (SVA)
* Multiple Testcases
* Regression Support

## Author

**Nayana Makani**
