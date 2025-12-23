# Defining a simple CPU in Verilog
- [x] 8 bit adder
- [x] subtraction with two's complement
- [x] 8-bit multiplexer
- [x] ALU
- [x] instruction fetch logic
- [x] lda, ldb
- [x] add, sub
- [x] sta
- [x] cmp, some branching
- [ ] call, ret
- [ ] push, pop
- [x] basic assembler
- [ ] make a spreadsheet describing what each of the instructions does over their clock cycles

## Running

0. Install [Icarus Verilog Compiler](https://bleyer.org/icarus/)
1. Assemble a program with `python util/assembler.py programs/fib.s` - this will write a `prog.mem` file that the verilog mocked memory will be initialized from.
2. Run the CPU on that memory with `make TB=cpu_tb`

## How will the `case` statements get compiled? Why are the control signals verilog `regs`?
TODO

## Resources
- [6502 Instruction Set](http://www.6502.org/users/obelisk/6502/instructions.html)
- [Ben Eater 8-bit Breadboard Computer](https://www.youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU)