---
title: "A CPU on an FPGA"
subtitle: "A 32-bit RISC processor in Verilog, with interrupts"
date: 2022-12-01
period: "October – December 2022"
weight: 45
status: stub
context: "ECE 4560 Modern Computing Systems"
role: "Verilog implementation, testing on the board, and the interrupt controller"
summary: "A single-cycle 32-bit RISC processor written in Verilog and run on a DE2-115 FPGA board, then extended to handle hardware interrupts."
stack: ["Verilog", "Quartus", "DE2-115 (Cyclone IV)"]
---
One of my first big projects at university, and still my favourite course. The processor is a single-cycle, 32-bit RISC design written in Verilog: eight registers, separate instruction and data memories, and results shown on the DE2-115's seven-segment displays.

## Adding interrupts

The last project added hardware interrupts to it:

- A push button raises an interrupt request. It's debounced and can arrive at any point in an instruction.
- An interrupt-enable bit masks requests, and one request can wait in a queue while they're masked.
- The interrupt routine sits at a fixed address, reached through a new input on the program-counter mux.
- The program counter and flags are saved to dedicated registers on entry, with `SEI`, `CLI` and `RTI` instructions to enable, disable and return.

To test it, I slowed the clock to one instruction every five seconds, so I could press the button partway through an instruction and watch the result on the board's LEDs.
