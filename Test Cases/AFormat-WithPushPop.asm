2                     ;the program starts at address 2
125                   ;ISR address

;rise Reset signal, R0=R1=R2=0d,R3=255d,PC=Mem[0]=2
;program
;set value 45d at In Port
In R0                 ;R0 = 45d
;set value 5d at In Port
In R1                 ;R1 = 5d

Mov R2, R0            ;R2 = 45d
ADD R2, R1	          ;R2 = 50d, CCR=VCNZ=0000
PUSH R0               ;Memory[255]=45d, R3(=SP)=254d, CCR=VCNZ=0000
PUSH R1               ;Memory[254]=5d, R3=253d
PUSH R2		          ;Memory[253]=50d, R3=252d 
POP R0                ;R0=50d, R3=253d          
POP R1		          ;R1=5d, R3=254
POP R2                ;R2=45d, R3=255

.125                ;go to address 125
RTI