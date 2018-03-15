# MIPS-Micoprocessor
* A simple pipelined processor, Harvard architecture.
* It is implemented in VHDL, simulated using Modelsim and synthesized using Synopsys design compiler and Quartus.

## Specifications
* The processor has a RISC-like instruction set architecture.
* Instructions are 1-byte or 2-bytes depending on the type of instructions.
* There are four 1-byte general purpose registers; R0, R1, R2, and R3. R3 also works as a stack pointer (SP); and hence; points to the top of the stack. The initial value of SP is 255. 
* The memory address space is 256 bytes and is byte addressable. When an interrupt occurs, the address of the instruction next to the interrupted instruction is saved on top of the stack, and PC is loaded from address 1 of the memory. 
* To return from an interrupt, an RTI instruction loads PC from the top of stack, and the flow of the program resumes from the instruction after the interrupted instruction.
* The pipeline consists of five stages (fetch, decode, execute, memory access & write back).
* The memory used is Harvard architecture memory, one separate memory for instructions and another one for data to avoid structural hazard between fetch and memory access stages.
* Unknown opcodes make the processor throw an exception and jump to ISR.
* The registers values are written in the first half of the clock cycle and read in the second half to avoid structural hazard between decode and write back stages.
* Data hazards are handled by implementing forwarding.
* There is a stall after any instructions reads a value from data memory and has data hazard with its next instruction.
  - ex: LDD R2,3
  - DEC R2
* Predict untaken technique is used in Branch and Jump instructions.
* Interrupt handling flushes only the instruction that exist in fetch stage and save its address to begin with after return from interrupt. All the others instructions in the pipeline run as usual.

### ISA Specifications:
![ISA](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/1%20ISA-Specs.PNG)

* Arithmetic operations are performed in two’s complement. Shift and logical operations are bit-wise. 
* There are 3 different instruction formats:

### A-Format:
These instructions are 1-byte. Op-code is the high order nibble and the low order nibble determines two registers.

![A-format1](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/2%20A-format.PNG)

Table I shows op-code values for A-format instructions and explains their functionality. R[ra] and R[rb] indicate values of registers ra and rb, respectively. For example: ADD r2, r1 instruction has op-code = 2, ra = 2, rb = 1, and bit stream of 00101001. Hence, the hexadecimal format of the instruction is: 0x29. The PUSH instruction writes the contents of register rb into the memory location addressed by SP. Then SP is decremented. In the POP instruction, SP is first incremented, and then, the contents of the memory location pointed to by SP are written into rb.

![A-format2](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/3%20A-format.PNG)

### B-Format:
B-format instructions are 1-byte and include instructions that break the sequential execution of programs.b-format instructions have op-code, ra “also named brx”, and rb. The brx field determines the type of the branch instruction.

![B-format1](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/4%20B-format.PNG)

Table II shows the details of B-format instructions. JMP instruction jumps to the destination address determined by the rb field. JZ is a conditional branch. If Z flag is one, it jumps to the destination address determined by rb. Similarly, JN, JC, and JV jump to the destination address determined by rb if N, C, and V flags are one, respectively. CALL is used for subroutine call. The processor has a dedicated pin for external interrupt. On the rising edge of the interrupt pin, the address of the next instruction is written into the stack and the SP is decremented (X[SP--] ← PC). PC is loaded from address 1 (PC ← M[1]), and processor jumps into interrupt service routine. Flags are also saved. At the end of the interrupt service routine, RTI instruction executes. RTI is similar to b-format instructions. It increments SP and load PC from the top of the stack. Flags are restored.

![B-format2](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/5%20B-format.PNG)

### L-Format
L-format instructions are either one or two bytes and are used for load/store instructions. For two bytes instructions, the second byte holds the address of memory or an immediate value.

![L-format1](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/6%20L-format.PNG)

Table III shows the details of L-format instructions. LDM writes a constant value (imm) into register rb. LDD and STD instructions use direct addressing. They read/write the contents of register rb from/into address ea. M[ea] means the content of a memory location with address ea. LDI and STI use indirect addressing. They read/write the contents of register rb from/into the memory location pointed to by ra. M[R[ra]] means the content of a memory location with address R[ra].

![L-format2](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/7%20L-format.PNG)

## Design Modules
#### 1- Register file
- Contains the four general purpose registers (R0, R1, R2, R3 (SP))
- It allows writing on two registers – one of them must be R3 - simultaneously.
#### 2- ALSU (Arithmetic logic shift unit)
- It performs the following operations:
![ALSU](https://github.com/abdallahmagdy1993/MIPS-Micoprocessor/blob/master/Images/ALSU.PNG)
#### 3- Data memory & instructions memory
- Each of them are 256 byte size, byte addressable and the same speed as processor (theoretical)
- We can read only – can’t write - from instruction memory.

### Pipline Stages
#### 1- Fetch stage:
- Contains the PC and contains the instruction memory
- Reads one byte as an instruction and puts the current PC and IR into IF_ID register
#### 2- Decode stage
- Contains the control unit that:
  * Decodes the coming instruction
  * Generates control signals to all the modules and stages depending on the instruction
  * Calculates the next PC and return it to fetch stage to get the next instruction
  * If a stall happened after load/pop instruction due to data hazard, the instructions that exist in the fetch & decode stage remains in the same place, the execute stage receives a bubble (NOP) from decode stage.
  * Responsible for handling interrupts and exceptions (unknown opcode)
#### 3- Execute stage:
- Contains ALSU and is responsible for changing flags
- Reading the value of IN_PORT in IN instruction
- Contains forwarding logic (get the forwarded values from memory access or write back)
- Calculate branch target address and check if the branch is taken or not
- Checks for stalling need after load instructions.
#### 4- Memory access stage
- Contains data memory unit.
- Is responsible for decrementing SP after push instruction
#### 5- Write back stage:
- Write the data required to be written in registers.
- Write the data in OUT_PORT in OUT instruction.

### Synthesization
* The processor is synthesized successfully with Quartus but it didn’t report the clock frequency, so we used Synopsys for synthesizing the processor with minimum clock period = 7ns and the timing constrains are MET
* Synopsys results an area = 126528
