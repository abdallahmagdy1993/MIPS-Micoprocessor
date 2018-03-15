2                   ;the program starts at address 2
125                 ;ISR address

;rise Reset signal, R0=R1=R2=0d,R3=255d,PC=Mem[0]=2
;program
;set value 15d at In Port
In R0               ;R0 = 15d
;set value 30d at In Port
In R1               ;R1 = 30d

NOP
NOP
;make an interrupt signal during the decoding or 
;the execution stage of the next instruction
SUB R0, R0   ;R0=0, CCR=VCNZ=0001
	         ;Mem[255]=PC, R3(SP)=254, PC=125, Flags Preserved!
NOP
NOP
NOP

.125
PUSH R0              ;Mem[R3]=0, R3--    ;assume we let SUB to continue execution and commit before interrupt handeling (thus R0=0, CCR=0001)
ADD R0, R1           ;R0=30, CCR=VCNZ=0000
POP R0               ;R3++, R0=0
RTI                  ;R3++, PC=Mem[R3], Flags restored (CCR=VCNZ=0001)
